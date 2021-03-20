import uuid

from django.db import models

# Create your models here.

POST_SUMMARY_LENGTH = 100


class Post(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    author = models.ForeignKey("accounts.User", on_delete=models.CASCADE)
    title = models.CharField(max_length=256)
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self) -> str:
        return f"({self.id}){self.title}"

    @property
    def sumamry(self) -> str:
        if len(self.content) > POST_SUMMARY_LENGTH:
            summary_len = POST_SUMMARY_LENGTH - 3
            return self.content[:summary_len] + "..."
        return self.content
