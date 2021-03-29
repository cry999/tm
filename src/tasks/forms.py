from django.forms import ModelForm, HiddenInput

from tasks.models import Task


class NewTaskForm(ModelForm):
    def __init__(self, *args, **kwargs) -> None:
        super().__init__(*args, **kwargs)

        initial = kwargs.get("initial", None)
        if initial and initial.get("project", None):
            self.fields["project"].widget.attrs["disabled"] = True

    class Meta:
        model = Task
        fields = (
            "project",
            "name",
            # belows are hidden field
            "parent",
        )
        widgets = {
            "parent": HiddenInput(),
        }


class EditTaskForm(ModelForm):
    class Meta:
        model = Task
        fields = (
            "project",
            "name",
            "detail",
            "status",
            "assignee",
            "priority",
            "deadline",
        )
