from django.db import models
from django.db.models import enums
from django.utils.translation import ugettext_lazy as _

from accounts.models import User
import uuid
from datetime import date

# Create your models here.


class Status(enums.TextChoices):
    TODO = "TODO"
    WIP = "WIP"
    DONE = "DONE"


class Task(models.Model):
    id = models.UUIDField(
        _("id"),
        primary_key=True,
        default=uuid.uuid4,
        editable=False,
        blank=True,
    )
    author = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name="tasks",
    )
    name = models.CharField(_("task name"), max_length=256)
    detail = models.TextField(
        _("task detail content"),
        default="",
        blank=True,
    )
    status = models.CharField(
        _("task status"),
        max_length=16,
        choices=Status.choices,
        default=Status.TODO,
        blank=True,
    )
    assignee = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name="assigned_tasks",
        blank=True,
        null=True,
    )
    deadline = models.DateField(_("deadline"), null=True, blank=True)
    created_at = models.DateTimeField(_("created at"), auto_now_add=True)
    updated_at = models.DateTimeField(_("updated at"), auto_now=True)

    @classmethod
    def created_by(cls, author: User, name: str) -> "Task":
        return cls(
            author=author,
            name=name,
            detail="",
            status=Status.TODO,
            deadline=None,
        )

    def set_content(self, content: str) -> None:
        self.content = content

    def set_deadline(self, deadline: date) -> None:
        assert deadline is not None
        self.deadline = deadline

    def start(self) -> None:
        self.status = Status.WIP

    def finish(self) -> None:
        self.status = Status.DONE
