from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models
from django.db.models import Q
from django.contrib.auth.models import User

# Custom manager for handling user creation
class UserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError("Users must have an email address")
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        if password:
            user.set_password(password)  # securely hashes the password
        else:
            user.set_unusable_password()  # in case no password provided (e.g., Google login)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)

        if not extra_fields.get('is_staff'):
            raise ValueError('Superuser must have is_staff=True')
        if not extra_fields.get('is_superuser'):
            raise ValueError('Superuser must have is_superuser=True')

        return self.create_user(email, password, **extra_fields)


# Custom User model that uses email for login and stores Firebase UID
class User(AbstractBaseUser, PermissionsMixin):
    firebase_uid = models.CharField(max_length=128, unique=True, null=True, blank=True)  # Make optional
    email = models.EmailField(unique=True)
    username = models.CharField(max_length=150, unique=True,)
    created_at = models.DateTimeField(auto_now_add=True)

    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    objects = UserManager()

    USERNAME_FIELD = 'email'  # Login field
    REQUIRED_FIELDS = ['username']

    def __str__(self):
        return self.email

   

    # 🔑 Allow login with either email or username
    @classmethod
    def get_user_by_identifier(cls, identifier):
        return cls.objects.filter(Q(email=identifier) | Q(username=identifier)).first()
    
    


CATEGORY_CHOICES = [
    ('mountains', 'Mountains'),
    ('temples', 'Temples'),
    ('rivers', 'Rivers'),
    ('city', 'City'),
    ('valley', 'Valley'),
    ('treks', 'Treks'),
    ('lakes', 'Lakes'),
]
class TravelPlace(models.Model):
    name = models.CharField(max_length=100)
    location = models.CharField(max_length=100)
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES)
    cover_image = models.ImageField(upload_to='travel_places/covers/', null=True)
    video = models.FileField(upload_to='travel_places/videos/', blank=True, null=True)
     # ✅ New Fields
    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)
    estimated_cost = models.CharField(max_length=200, null=True, blank=True)
    best_time_to_visit = models.CharField(max_length=200, null=True, blank=True)
    available_transport = models.TextField(null=True, blank=True)
    duration_to_visit = models.CharField(max_length=200, null=True, blank=True)
    full_address = models.TextField(null=True, blank=True)
    description = models.TextField()
    is_popular = models.BooleanField(default=False) 
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name


class TravelPlaceImage(models.Model):
    travel_place = models.ForeignKey(
        TravelPlace,
        on_delete=models.CASCADE,
        related_name='images'
    )
    image = models.ImageField(upload_to='travel_places/gallery/',null=True, blank=True)



CATEGORY_CHOICES = [
    ('mountains', 'Mountains'),
    ('temples', 'Temples'),
    ('rivers', 'Rivers'),
    ('city', 'City'),
    ('valley', 'Valley'),
    ('treks', 'Treks'),
    ('lakes', 'Lakes'),
]

class UserSubmittedPlace(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)  # Who submitted
    name = models.CharField(max_length=100)
    location = models.CharField(max_length=100)
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES)
    cover_image = models.ImageField(upload_to='user_places/covers/', null=True)
    video = models.FileField(upload_to='user_places/videos/', blank=True, null=True)

    # ✅ Required Fields for users
    latitude = models.FloatField()
    longitude = models.FloatField()

    estimated_cost = models.CharField(max_length=200, null=True, blank=True)
    best_time_to_visit = models.CharField(max_length=200, null=True, blank=True)
    available_transport = models.TextField(null=True, blank=True)
    duration_to_visit = models.CharField(max_length=200, null=True, blank=True)
    full_address = models.TextField(null=True, blank=True)
    description = models.TextField()

    is_approved = models.BooleanField(default=False)  # ✅ Admin can approve this later
    submitted_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.name} (User Submitted)"

class UserSubmittedPlaceImage(models.Model):
    place = models.ForeignKey(
        UserSubmittedPlace,
        on_delete=models.CASCADE,
        related_name='images'
    )
    image = models.ImageField(upload_to='user_places/gallery/')

    def __str__(self):
        return f"Image for {self.place.name}"
    
GENDER_CHOICES = [
    ('male', 'Male'),
    ('female', 'Female'),
    ('others', 'Others'),
    
]


class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    full_name = models.CharField(max_length=100, blank=True)
    dob = models.DateField(null=True, blank=True)
    gender = models.CharField(max_length=10,choices=GENDER_CHOICES)
    photo = models.ImageField(upload_to='profile_photos/', null=True, blank=True)

    bio = models.TextField(blank=True)
    followers = models.ManyToManyField('self', symmetrical=False, related_name='following', blank=True)

    def __str__(self):
        return self.user.username

    def follower_count(self):
        return self.followers.count() if self.followers else 0
    
    def following_count(self):
        return self.following.count()  if self.following else 0 



class Post(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='posts')
    caption = models.TextField(blank=True)
    media_type = models.CharField(max_length=10, choices=[('photo', 'Photo'), ('video', 'Video')])
    media_file = models.FileField(upload_to='user_posts/')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username}'s {self.media_type}"

class Notification(models.Model):
    NOTIFICATION_TYPES = (
        ('follow', 'Follow'),
        ('follow_back', 'Followed Back'),
        # Add more types if needed
    )

    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sent_notifications')
    receiver = models.ForeignKey(User, on_delete=models.CASCADE, related_name='received_notifications')
    notification_type = models.CharField(max_length=50, choices=NOTIFICATION_TYPES)
    message = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    is_read = models.BooleanField(default=False)
    timestamp = models.DateTimeField(auto_now=True)  # updated on each save
    is_active = models.BooleanField(default=True)    # 🔁 added field

    class Meta:
       
    #   constraints = [
    #     models.UniqueConstraint(fields=['sender', 'receiver', 'notification_type'], name='unique_notification')
    # ] 
     pass

    def __str__(self):
        return f'{self.sender} -> {self.receiver}: {self.notification_type}'
