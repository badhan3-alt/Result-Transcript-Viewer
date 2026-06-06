from rest_framework import serializers
from results.models import Result

class TranscriptSerializer(serializers.ModelSerializer):
    course_name = serializers.CharField(source='course.course_name')
    course_code = serializers.CharField(source='course.course_code')
    credit = serializers.IntegerField(source='course.credit')

    class Meta:
        model = Result
        fields = [
            'course_code',
            'course_name',
            'credit',
            'grade',
            'grade_point',
            'semester'
        ]