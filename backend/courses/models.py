from django.db import models

# Create your models here.
from django.db import models

class Course(models.Model):
    course_code = models.CharField(max_length=20, unique=True)
    course_name = models.CharField(max_length=200)
    credit = models.IntegerField()

    def __str__(self):
        return f"{self.course_code} - {self.course_name}"

class OfferedCourse(models.Model):
    course = models.ForeignKey(Course, on_delete=models.CASCADE)
    DEPARTMENT_CHOICES = [
        ('CSE', 'Computer Science & Engineering'),
        ('LAW', 'Law'),
        ('Eng', 'English'),
        ('BBA', 'Business Administration'),
    ]
    department = models.CharField(max_length=100, choices=DEPARTMENT_CHOICES)
    batch = models.CharField(max_length=20)
    semester = models.IntegerField()

    def __str__(self):
        return f"{self.course.course_code} for {self.department} ({self.batch}) - Sem {self.semester}"