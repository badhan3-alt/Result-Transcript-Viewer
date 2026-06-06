from rest_framework import serializers
from .models import Transaction

class TransactionSerializer(serializers.ModelSerializer):
    amount = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)

    class Meta:
        model = Transaction
        fields = '__all__'
        read_only_fields = ('amount',)
        extra_kwargs = {
            'student': {'required': False, 'allow_null': True},
        }
