from django.forms import ModelForm

from tasks.models import Task


class NewTaskForm(ModelForm):
    class Meta:
        model = Task
        fields = ("name",)


class EditTaskForm(ModelForm):
    class Meta:
        model = Task
        fields = (
            "name",
            "detail",
            "status",
            "assignee",
            "priority",
            "deadline",
        )
