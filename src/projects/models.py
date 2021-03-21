import re
import uuid

from django.core.validators import RegexValidator
from django.db import models
from django.utils.deconstruct import deconstructible
from django.utils.translation import ugettext_lazy as _

# Create your models here.


@deconstructible
class VersionValidator(RegexValidator):
    regex = r"^[0-9]+.[0-9]+.[0-9]+$"
    message = (
        "Enter a valid version. This value should be <major>.<minor>.<patch>, and"
        " all fields should contain only numbers."
    )
    flags = re.ASCII


class Project(models.Model):
    id = models.UUIDField(primary_key=True, editable=False, default=uuid.uuid4)
    name = models.CharField(max_length=128)
    owner = models.ForeignKey(
        "accounts.User",
        on_delete=models.CASCADE,
        related_name="projects",
    )
    elevator_pitch = models.CharField(
        _("short summary of what you want to achieve"),
        max_length=512,
    )
    version = models.CharField(
        max_length=32,
        validators=[VersionValidator],
        default="0.0.0",
    )

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self) -> str:
        return self.name
