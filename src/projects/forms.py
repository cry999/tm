from django.forms import ModelForm

from projects.models import Project


class NewProjectForm(ModelForm):
    class Meta:
        model = Project
        fields = (
            "name",
            "elevator_pitch",
        )


class EditProjectForm(ModelForm):
    class Meta:
        model = Project
        fields = (
            "name",
            "elevator_pitch",
            "version",  # TODO version should be updated via milestone / sprint
        )
