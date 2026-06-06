from django.shortcuts import render

# Create your views here.
from rest_framework import generics
from .models import Result
from .serializers import ResultSerializer
from rest_framework.response import Response
from rest_framework.views import APIView

class ResultListCreateView(generics.ListCreateAPIView):
    queryset = Result.objects.all()
    serializer_class = ResultSerializer


class ResultDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Result.objects.all()
    serializer_class = ResultSerializer


class StudentResultView(APIView):
    def get(self, request, student_id):
        results = Result.objects.filter(student__student_id=student_id)
        semester = request.query_params.get('semester')
        if semester:
            results = results.filter(semester=semester)
        serializer = ResultSerializer(results, many=True)
        return Response(serializer.data)