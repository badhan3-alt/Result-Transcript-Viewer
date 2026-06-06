from decimal import Decimal

from rest_framework import generics, serializers
from .models import Transaction
from .serializers import TransactionSerializer
from rest_framework.permissions import AllowAny # For dev
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
import random
from django.core.mail import send_mail
from django.conf import settings
from users.models import OTPVerification, Student

class StudentTransactionListView(generics.ListAPIView):
    serializer_class = TransactionSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        student_id = self.request.query_params.get('student_id')
        if student_id:
            return Transaction.objects.filter(student__student_id=student_id).order_by('-created_at')
        return Transaction.objects.none()

class SendPaymentOTPView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        email = request.data.get('email')
        if not email:
            return Response({"error": "Email is required"}, status=status.HTTP_400_BAD_REQUEST)

        otp = str(random.randint(100000, 999999))
        
        # Save OTP (update if exists)
        OTPVerification.objects.filter(email__iexact=email).delete()
        OTPVerification.objects.create(email=email, otp=otp)

        # Print to terminal
        print("\n" + "="*60)
        print(f"=== PAYMENT OTP FOR {email}: [ {otp} ] ===")
        print("="*60 + "\n")

        # Send Real Email
        email_sent = False
        try:
            send_mail(
                'Academic Ledger - Payment Confirmation OTP',
                f'Your OTP for payment confirmation is: {otp}. This code will expire in 10 minutes.',
                settings.EMAIL_HOST_USER,
                [email],
                fail_silently=False,
            )
            email_sent = True
        except Exception as e:
            print(f"!!! PAYMENT EMAIL FAILED: {e}")

        return Response({
            "message": "OTP sent",
            "email_sent": email_sent,
            "otp_in_terminal": otp if not email_sent else None
        }, status=status.HTTP_200_OK)

class TransactionCreateView(generics.CreateAPIView):
    queryset = Transaction.objects.all()
    serializer_class = TransactionSerializer
    permission_classes = [AllowAny]
    PER_CREDIT_FEE = Decimal(getattr(settings, 'PAYMENT_PER_CREDIT_FEE', '1000.00'))

    def _calculate_amount_for_student(self, student):
        from courses.models import OfferedCourse

        offered_courses = OfferedCourse.objects.filter(
            department=student.department,
            batch=student.batch,
            semester=student.current_semester,
        )
        total_credits = sum((offered.course.credit for offered in offered_courses), 0)
        return self.PER_CREDIT_FEE * Decimal(total_credits)

    def post(self, request, *args, **kwargs):
        email = request.data.get('email')
        otp = request.data.get('otp')
        
        if not email or not otp:
            return Response({"error": "Email and OTP are required"}, status=status.HTTP_400_BAD_REQUEST)
            
        try:
            otp_obj = OTPVerification.objects.get(email__iexact=email, otp=otp)
            if not otp_obj.is_valid():
                return Response({"error": "OTP has expired"}, status=status.HTTP_400_BAD_REQUEST)
        except OTPVerification.DoesNotExist:
            return Response({"error": "Invalid OTP"}, status=status.HTTP_400_BAD_REQUEST)

        # If OTP is valid, proceed with creation
        response = super().post(request, *args, **kwargs)
        if response.status_code == 201:
            otp_obj.delete() # Cleanup
        return response

    def perform_create(self, serializer):
        student_id_str = self.request.data.get('student_id_str') or self.request.data.get('student_id')
        email = self.request.data.get('email')
        student = None

        if student_id_str:
            try:
                student = Student.objects.get(student_id=student_id_str)
            except Student.DoesNotExist:
                student = None

        if not student and email:
            student = Student.objects.filter(email__iexact=email).first()

        if not student:
            raise serializers.ValidationError({
                'student': 'Student not found for provided student_id_str or email.'
            })

        amount = self._calculate_amount_for_student(student)
        serializer.save(student=student, amount=amount, status='completed')
