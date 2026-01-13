#!/usr/bin/env python3
"""
Generate Android and iOS icons from a source image.
Place source image as 'ic_launcher.png' in the root.
"""
from PIL import Image
import os
import shutil

def resize_and_save(source_path, output_path, size):
    """Resize source image to given size and save as PNG."""
    try:
        img = Image.open(source_path)
        # Ensure square
        if img.size[0] != img.size[1]:
            # Crop to square centered
            min_dim = min(img.size)
            left = (img.size[0] - min_dim) // 2
            top = (img.size[1] - min_dim) // 2
            img = img.crop((left, top, left + min_dim, top + min_dim))
        img = img.resize((size, size), Image.Resampling.LANCZOS)
        img.save(output_path, 'PNG')
        print(f"Generated {output_path} ({size}x{size})")
    except Exception as e:
        print(f"Error processing {output_path}: {e}")

def main():
    source = 'ic_launcher.png'
    if not os.path.exists(source):
        print(f"Source image {source} not found.")
        return

    # Android icon sizes
    android_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }
    
    # Generate Android icons
    for folder, size in android_sizes.items():
        os.makedirs(f'android/app/src/main/res/{folder}', exist_ok=True)
        output = f'android/app/src/main/res/{folder}/ic_launcher.png'
        resize_and_save(source, output, size)
    
    # iOS icon sizes (from Contents.json)
    ios_sizes = [
        (20, 1), (20, 2), (20, 3),
        (29, 1), (29, 2), (29, 3),
        (40, 1), (40, 2), (40, 3),
        (50, 1), (50, 2),
        (57, 1), (57, 2),
        (60, 2), (60, 3),
        (72, 1), (72, 2),
        (76, 1), (76, 2),
        (83.5, 2),
        (1024, 1),
    ]
    
    ios_dir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    os.makedirs(ios_dir, exist_ok=True)
    
    for base_size, scale in ios_sizes:
        size = int(base_size * scale)
        filename = f'Icon-App-{base_size}x{base_size}@{scale}x.png'
        output = os.path.join(ios_dir, filename)
        resize_and_save(source, output, size)
    
    print("All icons generated successfully.")

if __name__ == '__main__':
    main()