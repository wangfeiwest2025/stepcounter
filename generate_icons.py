from PIL import Image, ImageDraw, ImageFont
import os

def create_step_counter_icon(size, is_windows=False):
    """Create a step counter themed icon"""
    # Create a new image with transparent background
    icon = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(icon)
    
    # Background circle (blue gradient would be ideal, but we'll use solid color)
    draw.ellipse([0, 0, size-1, size-1], fill='#4285F4')  # Google blue color
    
    # Draw a simplified step counter design
    # Person figure
    center_x, center_y = size // 2, size // 2
    
    # Head
    head_radius = size // 8
    draw.ellipse([center_x - head_radius, center_y - head_radius*3, 
                  center_x + head_radius, center_y - head_radius], fill='white')
    
    # Body
    draw.line((center_x, center_y - head_radius, center_x, center_y + head_radius), 
              fill='white', width=size//15)
    
    # Legs (in walking position)
    leg_length = size // 4
    draw.line((center_x, center_y + head_radius, center_x - leg_length//2, center_y + head_radius + leg_length), 
              fill='white', width=size//20)
    draw.line((center_x, center_y + head_radius, center_x + leg_length//2, center_y + head_radius + leg_length//2), 
              fill='white', width=size//20)
    
    # Arms
    arm_length = size // 3
    draw.line((center_x, center_y, center_x - arm_length//2, center_y - arm_length//3), 
              fill='white', width=size//20)
    draw.line((center_x, center_y, center_x + arm_length//2, center_y - arm_length//4), 
              fill='white', width=size//20)
    
    # Step count indicator (simplified)
    if not is_windows and size >= 96:  # For larger icons, add text
        font_size = max(10, size // 4)
        try:
            # Try to use a basic font
            font = ImageFont.truetype("arial.ttf", font_size)
        except:
            # Fallback to default font
            font = ImageFont.load_default()
        
        # Draw step count text
        text = "SC"
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        draw.text((center_x - text_width//2, center_y + head_radius*2), text, fill='white', font=font)
    
    return icon

def create_windows_icon():
    """Create a Windows ICO file with multiple sizes"""
    # Create images for different sizes
    sizes = [16, 24, 32, 48, 64, 128, 256]
    images = []
    
    for size in sizes:
        img = create_step_counter_icon(size, is_windows=True)
        images.append(img)
    
    # Save as ICO
    images[0].save('windows/runner/resources/app_icon.ico', format='ICO', 
                   append_images=images[1:], sizes=[(s, s) for s in sizes])
    print("Windows ICO file created: windows/runner/resources/app_icon.ico")

def main():
    # Create directories if they don't exist
    os.makedirs('android/app/src/main/res/mipmap-mdpi', exist_ok=True)
    os.makedirs('android/app/src/main/res/mipmap-hdpi', exist_ok=True)
    os.makedirs('android/app/src/main/res/mipmap-xhdpi', exist_ok=True)
    os.makedirs('android/app/src/main/res/mipmap-xxhdpi', exist_ok=True)
    os.makedirs('android/app/src/main/res/mipmap-xxxhdpi', exist_ok=True)
    os.makedirs('windows/runner/resources', exist_ok=True)
    
    # Android icon sizes (mdpi base is 48px)
    android_sizes = {
        'mipmap-mdpi': 48,      # mdpi
        'mipmap-hdpi': 72,      # hdpi (1.5x)
        'mipmap-xhdpi': 96,     # xhdpi (2x)
        'mipmap-xxhdpi': 144,   # xxhdpi (3x)
        'mipmap-xxxhdpi': 192   # xxxhdpi (4x)
    }
    
    # Generate Android icons
    for folder, size in android_sizes.items():
        icon = create_step_counter_icon(size)
        path = f'android/app/src/main/res/{folder}/ic_launcher.png'
        icon.save(path)
        print(f"Android icon created: {path}")
    
    # Generate Windows icon
    create_windows_icon()
    
    print("All icons generated successfully!")

if __name__ == "__main__":
    main()