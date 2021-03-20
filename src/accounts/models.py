import re
import uuid

from django.contrib.auth.base_user import AbstractBaseUser
from django.contrib.auth.models import PermissionsMixin, UserManager
from django.core.validators import RegexValidator
from django.db import models
from django.utils.deconstruct import deconstructible
from django.utils.translation import ugettext_lazy as _

# Create your models here.


@deconstructible
class UsernameValidator(RegexValidator):
    regex = r"^[0-9a-z-]+$"
    message = (
        "Enter a valid username. This value may contain only English small"
        " letters, numbers and hyphen."
    )
    flags = re.ASCII


class User(AbstractBaseUser, PermissionsMixin):
    # username を ASCII に限定することで、Unicode 文字の紛らわしい文字の混入を防ぎ、
    # なりすましを防ぐことにつながる
    username_validator = UsernameValidator

    id = models.UUIDField(_("id"), primary_key=True, default=uuid.uuid4, editable=False)
    username = models.CharField(
        _("username"),
        max_length=128,
        unique=True,
        help_text=_(
            "Required. 128 characters of fewer. Letters, digits and @.+-_ only."
        ),
        validators=[username_validator],
        error_messages={"unique": _("A user with that username already exists.")},
    )
    email = models.EmailField(_("email address"), blank=True)

    is_admin = models.BooleanField(default=False)
    is_staff = models.BooleanField(
        _("staff status"),
        default=False,
        help_text=_("Designates whether the user can log into this admin site."),
    )
    is_active = models.BooleanField(
        _("active"),
        default=True,
        help_text=_(
            "Designates whether this user should be treated as active."
            " Unselect this instead of deleting accounts."
        ),
    )
    created_at = models.DateTimeField(_("date joined"), auto_now_add=True)
    updated_at = models.DateTimeField(_("date updated"), auto_now=True)

    objects = UserManager()

    EMAIL_FIELD = "email"
    USERNAME_FIELD = "username"
    REQUIRED_FIELDS = ["email"]

    class Meta:
        verbose_name = _("user")
        verbose_name_plural = _("users")
        db_table = "users"

    def clean(self) -> None:
        super().clean()
        self.email = self.__class__.objects.normalize_email(self.email)
