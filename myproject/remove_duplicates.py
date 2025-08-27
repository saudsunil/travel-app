import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'myproject.settings')
django.setup()

from api.models import Notification
from django.db.models import Count

duplicates = (
    Notification.objects
    .values('sender', 'receiver', 'notification_type')
    .annotate(count=Count('id'))
    .filter(count__gt=1)
)

print(f"Found {duplicates.count()} duplicate groups")

for group in duplicates:
    notifs = Notification.objects.filter(
        sender=group['sender'],
        receiver=group['receiver'],
        notification_type=group['notification_type']
    ).order_by('created_at')

    to_delete = notifs[1:]  # keep first, delete the rest
    ids_to_delete = [notif.id for notif in to_delete]
    print(f"Deleting notifications with IDs: {ids_to_delete}")

    Notification.objects.filter(id__in=ids_to_delete).delete()
