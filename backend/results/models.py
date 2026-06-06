from django.db import models

# Create your models here.
from django.db import models
from users.models import Student
from courses.models import Course

class Result(models.Model):
    GRADE_CHOICES = [
        ("A+", "A+"),
        ("A", "A"),
        ("A-", "A-"),
        ("B+", "B+"),
        ("B", "B"),
        ("B-", "B-"),
        ("C+", "C+"),
        ("C", "C"),
        ("D", "D"),
        ("F", "F"),
    ]

    student = models.ForeignKey(Student, on_delete=models.CASCADE)
    course = models.ForeignKey(Course, on_delete=models.CASCADE)

    grade = models.CharField(max_length=2, choices=GRADE_CHOICES)
    grade_point = models.FloatField()

    semester = models.IntegerField()

    created_at = models.DateTimeField(auto_now_add=True)

    def save(self, *args, **kwargs):
        # Auto-calculate grade points based on letter grade
        grade_map = {
            "A+": 4.0, "A": 3.75, "A-": 3.50,
            "B+": 3.25, "B": 3.0, "B-": 2.75,
            "C+": 2.5, "C": 2.25, "D": 2.0, "F": 0.0
        }
        self.grade_point = grade_map.get(self.grade, 0.0)
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.student.email} - {self.course.course_code}"