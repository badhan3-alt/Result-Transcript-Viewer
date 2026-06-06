from rest_framework import serializers
from .models import Result

class ResultSerializer(serializers.ModelSerializer):
    student_name = serializers.CharField(source='student.username', read_only=True)
    course_name = serializers.CharField(source='course.course_name', read_only=True)
    course_code = serializers.CharField(source='course.course_code', read_only=True)
    credit = serializers.IntegerField(source='course.credit', read_only=True)

    class Meta:
        model = Result
        fields = [
            'id',
            'student',
            'student_name',
            'course',
            'course_name',
            'course_code',
            'credit',
            'grade',
            'grade_point',
            'semester'
        ]
        read_only_fields = ['grade_point']