from django.shortcuts import render
from rest_framework import generics
from .models import Course, OfferedCourse
from .serializers import CourseSerializer, OfferedCourseSerializer
from rest_framework.views import APIView
from rest_framework.response import Response

class CourseListCreateView(generics.ListCreateAPIView):
    queryset = Course.objects.all()
    serializer_class = CourseSerializer


class CourseDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Course.objects.all()
    serializer_class = CourseSerializer

class OfferedCourseListView(generics.ListCreateAPIView):
    serializer_class = OfferedCourseSerializer

    def get_queryset(self):
        queryset = OfferedCourse.objects.all()
        department = self.request.query_params.get('department')
        batch = self.request.query_params.get('batch')
        semester = self.request.query_params.get('semester')
        student_id = self.request.query_params.get('student_id') # the "roll"

        if student_id:
            from users.models import Student
            try:
                student = Student.objects.get(student_id=student_id)
                department = student.department
                batch = student.batch
                if not semester:
                    semester = student.current_semester
            except Student.DoesNotExist:
                pass
        
        if department:
            queryset = queryset.filter(department=department)
        if batch:
            queryset = queryset.filter(batch=batch)
        if semester:
            queryset = queryset.filter(semester=semester)
            
        return queryset

    def post(self, request, *args, **kwargs):
        # We can add a permission check here for 'teacher' role if needed
        return super().post(request, *args, **kwargs)