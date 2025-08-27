
# Register your models here.


from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.utils.translation import gettext_lazy as _
from .models import User
from .models import TravelPlace, TravelPlaceImage, UserSubmittedPlace, UserSubmittedPlaceImage, Notification
from .models import UserProfile, Post
from django.utils.html import format_html

@admin.register(User)
class UserAdmin(BaseUserAdmin):
    # Fields to display in the user list view
    list_display = ('email', 'firebase_uid', 'username', 'is_staff', 'is_active', 'created_at')
    list_filter = ('is_staff', 'is_active', 'is_superuser')

    # Fields to search by
    search_fields = ('email', 'firebase_uid', 'username')

    # Ordering of user list
    ordering = ('email',)

    # Fields shown in user detail page in admin (change/add as needed)
    fieldsets = (
        (None, {'fields': ('email', 'password', 'firebase_uid')}),
        ('Personal Info', {'fields': ('username',)}),
        ('Permissions', {'fields': ('is_staff', 'is_active', 'is_superuser', 'groups', 'user_permissions')}),
        ('Important dates', {'fields': ('last_login',)}),
    )

    # Fields shown when creating a new user via admin
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'firebase_uid', 'username', 'password1', 'password2', 'is_staff', 'is_active'),
        }),
    )



class TravelPlaceImageInline(admin.TabularInline):
    model = TravelPlaceImage
    extra = 1



@admin.register(TravelPlace)
class TravelPlaceAdmin(admin.ModelAdmin):
    inlines = [TravelPlaceImageInline]
    list_display = ['name', 'category', 'location', 'created_at']
    search_fields = ('name', 'location', 'category')
    list_filter = ['category']
    

admin.site.register(TravelPlaceImage)



class UserSubmittedPlaceImageInline(admin.TabularInline):
    model = UserSubmittedPlaceImage
    extra = 1

@admin.register(UserSubmittedPlace)
class UserSubmittedPlaceAdmin(admin.ModelAdmin):
    list_display = ['name', 'category', 'user', 'is_approved', 'submitted_at']
    list_filter = ['is_approved', 'category']
    search_fields = ('name', 'location', 'category')
    inlines = [UserSubmittedPlaceImageInline]
    
    
admin.site.register( UserSubmittedPlaceImage)




@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ['user', 'photo_thumbnail', 'bio', 'follower_count', 'following_count']
    search_fields = ['user__email', 'user__username']
    readonly_fields = ['follower_count', 'following_count']

    def follower_count(self, obj):
        return obj.follower_count()

    def following_count(self, obj):
        return obj.following_count()

    follower_count.short_description = 'Followers'
    following_count.short_description = 'Following'

    def photo_thumbnail(self, obj):
        if obj.photo:
            return format_html('<img src="{}" style="width: 50px; height:50px; object-fit: cover; border-radius: 50%;" />', obj.photo.url)
        return '-'

    photo_thumbnail.short_description = 'Photo'

@admin.register(Post)
class PostAdmin(admin.ModelAdmin):
    list_display = ['user', 'media_type', 'created_at']
    search_fields = ['user__email', 'user__username']
    list_filter = ['media_type', 'created_at']
    
    


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ('id', 'sender', 'receiver', 'notification_type', 'is_read', 'is_active', 'created_at')
    list_filter = ('notification_type', 'is_read', 'is_active')
    search_fields = ('sender__email', 'receiver__email', 'message')
    ordering = ('-created_at',)