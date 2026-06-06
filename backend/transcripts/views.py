from django.shortcuts import render

# Create your views here.
from rest_framework.views import APIView
from rest_framework.response import Response
from results.models import Result
from results.serializers import ResultSerializer

class TranscriptView(APIView):
    def get(self, request, student_id):
        results = Result.objects.filter(student_id=student_id)
        serializer = ResultSerializer(results, many=True)

        # Simple GPA logic (you should move to services.py later)
        total_points = 0
        total_credits = 0

        for r in results:
            total_points += r.grade_point * r.course.credit
            total_credits += r.course.credit

        cgpa = total_points / total_credits if total_credits > 0 else 0

        return Response({
            "results": serializer.data,
            "cgpa": round(cgpa, 2)
        })