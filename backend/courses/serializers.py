from rest_framework import serializers
from .models import Course, OfferedCourse

class CourseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Course
        fields = '__all__'

class OfferedCourseSerializer(serializers.ModelSerializer):
    course_details = CourseSerializer(source='course', read_only=True)
    
    class Meta:
        model = OfferedCourse
        fields = ['id', 'course', 'course_details', 'department', 'batch', 'semester']