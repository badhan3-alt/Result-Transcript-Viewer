from django.db import models

# Create your models here.
from django.db import models
from users.models import Student

class Transcript(models.Model):
    student = models.ForeignKey(Student, on_delete=models.CASCADE)
    cgpa = models.FloatField()
    generated_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Transcript - {self.student.email}"