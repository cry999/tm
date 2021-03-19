from django.contrib import admin
from django.contrib.auth.admin import UserAdmin

from .models import User

# Register your models here.


@admin.register(User)
class AdminUserAdmin(UserAdmin):
    fieldsets = ((None, {"fields": ("username", "email", "password")}),)
    list_display = ("username", "email", "username", "is_staff")
