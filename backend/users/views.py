from django.shortcuts import render
from django.conf import settings
from rest_framework.views import APIView
from rest_framework.response import Response
from django.contrib.auth import authenticate
from rest_framework import status
from .models import Student, OTPVerification, PendingRegistration
from .serializers import StudentSerializer
import random
from django.core.mail import send_mail
from rest_framework.permissions import IsAuthenticated, AllowAny
from .permissions import IsStudent, IsTeacher

class RegisterView(APIView):
    def post(self, request):
        email = request.data.get('email')
        username = request.data.get('username')
        user_type = request.data.get('user_type', 'student')
        student_id = request.data.get('student_id')
        
        # 1. Basic validation
        if not email or not username:
            return Response({"error": "Email and Username are required."}, status=status.HTTP_400_BAD_REQUEST)

        # 2. Check if already fully registered
        if Student.objects.filter(email__iexact=email).exists():
            return Response({"error": "An account with this email already exists."}, status=status.HTTP_400_BAD_REQUEST)
        
        if user_type == 'student' and student_id:
            if Student.objects.filter(student_id=student_id).exists():
                return Response({"error": "A student with this ID already exists."}, status=status.HTTP_400_BAD_REQUEST)

        # 3. Generate OTP
        otp = str(random.randint(100000, 999999))
        
        # 4. Save to PendingRegistration (overwrite if exists)
        PendingRegistration.objects.filter(email__iexact=email).delete()
        PendingRegistration.objects.create(
            email=email,
            username=username,
            password=request.data.get('password'),
            student_id=student_id,
            department=request.data.get('department'),
            batch=request.data.get('batch'),
            user_type=user_type,
            otp=otp
        )
        
        # 5. Print OTP to terminal for development
        print("\n" + "*"*60)
        print(f"*** REGISTRATION OTP FOR {email} ({user_type.upper()}): [ {otp} ]")
        print("*"*60 + "\n")
        
        # 6. Send Real Email
        email_sent = False
        try:
            send_mail(
                'Verify your Academic Ledger Account',
                f'Your OTP for registration is: {otp}',
                settings.EMAIL_HOST_USER,
                [email],
                fail_silently=False,
            )
            email_sent = True
        except Exception as e:
            print(f"!!! REAL EMAIL FAILED: {e}")
            email_sent = False
        
        return Response(
            {
                "message": "OTP initiated.", 
                "email": email,
                "email_sent": email_sent,
                "otp_in_terminal": otp if not email_sent else None
            }, 
            status=status.HTTP_201_CREATED
        )

class VerifyOTPView(APIView):
    def post(self, request):
        email = request.data.get('email')
        otp = request.data.get('otp')
        
        try:
            pending = PendingRegistration.objects.get(email__iexact=email, otp=otp)
            if pending.is_valid():
                # Now create the actual Student account
                serializer = StudentSerializer(data={
                    'username': pending.username,
                    'email': pending.email,
                    'password': pending.password,
                    'student_id': pending.student_id,
                    'department': pending.department,
                    'batch': pending.batch,
                    'user_type': pending.user_type
                })
                
                if serializer.is_valid():
                    user = serializer.save()
                    pending.delete() # cleanup
                    return Response({
                        "message": "Account created successfully!",
                        "student_id": user.id,
                        "user_type": user.user_type,
                        "email": user.email,
                        "username": user.username,
                        "student_id_str": user.student_id,
                        "department": user.department,
                        "batch": user.batch,
                        "current_semester": user.current_semester,
                        "academic_year": user.academic_year,
                        "faculty_adviser": user.faculty_adviser,
                        "enrollment_status": user.enrollment_status
                    }, status=status.HTTP_200_OK)
                
                # Format serializer errors into a readable string
                error_details = []
                for field, errors in serializer.errors.items():
                    error_details.append(f"{field}: {', '.join(errors)}")
                error_msg = " | ".join(error_details)
                return Response({"error": error_msg}, status=status.HTTP_400_BAD_REQUEST)
            else:
                return Response({"error": "OTP has expired."}, status=status.HTTP_400_BAD_REQUEST)
        except PendingRegistration.DoesNotExist:
            return Response({"error": "Invalid OTP or Email."}, status=status.HTTP_400_BAD_REQUEST)
class LoginView(APIView):
    def post(self, request):
        email = request.data.get("email")
        password = request.data.get("password")

        user = authenticate(username=email, password=password)

        if user:
            return Response({
                "message": "Login successful",
                "student_id": user.id,
                "user_type": user.user_type,
                "email": user.email,
                "username": user.username,
                "student_id_str": user.student_id,
                "department": user.department,
                "batch": user.batch,
                "current_semester": user.current_semester,
                "academic_year": user.academic_year,
                "faculty_adviser": user.faculty_adviser,
                "enrollment_status": user.enrollment_status
            }, status=status.HTTP_200_OK)
        return Response({"error": "Invalid credentials"}, status=status.HTTP_401_UNAUTHORIZED)


class ForgotPasswordView(APIView):
    def post(self, request):
        email = request.data.get('email')
        if not email:
            return Response({"error": "Email is required."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            user = Student.objects.get(email__iexact=email)
        except Student.DoesNotExist:
            return Response({"error": "No account found with this email."}, status=status.HTTP_404_NOT_FOUND)

        otp = str(random.randint(100000, 999999))
        OTPVerification.objects.filter(email__iexact=email).delete()
        OTPVerification.objects.create(email=email, otp=otp)

        # Print OTP for development
        print("\n" + "="*60)
        print(f"=== PASSWORD RESET OTP FOR {email}: [ {otp} ] ===")
        print("="*60 + "\n")

        # Send Email
        try:
            send_mail(
                'Password Reset OTP - Academic Ledger',
                f'Your OTP for password reset is: {otp}',
                settings.EMAIL_HOST_USER,
                [email],
                fail_silently=False,
            )
            email_sent = True
        except Exception as e:
            print(f"!!! RESET EMAIL FAILED: {e}")
            email_sent = False

        return Response({
            "message": "OTP sent to your email.",
            "email_sent": email_sent,
            "otp_in_terminal": otp if not email_sent else None
        }, status=status.HTTP_200_OK)

class ResetPasswordView(APIView):
    def post(self, request):
        email = request.data.get('email')
        otp = request.data.get('otp')
        new_password = request.data.get('new_password')

        if not all([email, otp, new_password]):
            return Response({"error": "Email, OTP and new password are required."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            verification = OTPVerification.objects.get(email__iexact=email, otp=otp)
            if not verification.is_valid():
                return Response({"error": "OTP has expired."}, status=status.HTTP_400_BAD_REQUEST)
            
            user = Student.objects.get(email__iexact=email)
            user.set_password(new_password)
            user.save()
            
            verification.delete()
            return Response({"message": "Password reset successful!"}, status=status.HTTP_200_OK)
            
        except OTPVerification.DoesNotExist:
            return Response({"error": "Invalid OTP or Email."}, status=status.HTTP_400_BAD_REQUEST)
        except Student.DoesNotExist:
            return Response({"error": "User no longer exists."}, status=status.HTTP_404_NOT_FOUND)


class ProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = StudentSerializer(request.user)
        return Response(serializer.data, status=status.HTTP_200_OK)

class StudentListView(APIView):
    permission_classes = [AllowAny] # Changed from IsTeacher to AllowAny for development

    def get(self, request):
        department = request.query_params.get('department')
        
        # If no department is provided but the user is a teacher, use the teacher's department
        if not department and request.user.is_authenticated and request.user.user_type == 'teacher':
            department = request.user.department
            
        if department:
            students = Student.objects.filter(department=department, user_type='student')
        else:
            students = Student.objects.filter(user_type='student')
        
        serializer = StudentSerializer(students, many=True)
        return Response(serializer.data)

class UpdateStudentStatusView(APIView):
    permission_classes = [IsTeacher] # Only teachers can update student status

    def patch(self, request, pk):
        try:
            student = Student.objects.get(pk=pk, user_type='student')
        except Student.DoesNotExist:
            return Response({"error": "Student not found"}, status=status.HTTP_404_NOT_FOUND)
        
        # Only allow updating specific fields as per requirements
        allowed_fields = ['current_semester', 'enrollment_status', 'academic_year']
        update_data = {k: v for k, v in request.data.items() if k in allowed_fields}
        
        serializer = StudentSerializer(student, data=update_data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)