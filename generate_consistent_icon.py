import os
from PIL import Image

def create_notification_icon():
    # 源文件路径 (使用最高分辨率的图标)
    source_path = r'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png'
    # 目标路径
    target_path = r'android/app/src/main/res/drawable/ic_notification.png'

    if not os.path.exists(source_path):
        print(f"Error: Source file not found at {source_path}")
        # 尝试查找其他分辨率
        for dpi in ['xxhdpi', 'xhdpi', 'hdpi', 'mdpi']:
            alt_path = f'android/app/src/main/res/mipmap-{dpi}/ic_launcher.png'
            if os.path.exists(alt_path):
                source_path = alt_path
                print(f"Found alternative source at {source_path}")
                break
        else:
            return

    print(f"Processing {source_path}...")
    
    try:
        img = Image.open(source_path).convert("RGBA")
        datas = img.getdata()
        
        # 创建新的像素数据
        new_data = []
        
        # 我们的目标是提取白色内容（小人和文字），去除蓝色背景
        # icon通常是蓝色背景+白色前景
        
        for item in datas:
            # item is (r, g, b, a)
            # 简单的颜色分离：
            # 如果像素接近白色 (R,G,B > 200)，我们要保留它且保持白色
            # 如果像素是蓝色背景，我们要让它变透明
            
            # 判断白色的阈值
            if item[0] > 200 and item[1] > 200 and item[2] > 200:
                # 它是白色（前景），保持白色不透明
                new_data.append((255, 255, 255, 255))
            else:
                # 它是背景（或其他颜色），设为全透明
                new_data.append((255, 255, 255, 0))

        img.putdata(new_data)
        
        # 调整大小为标准的通知图标尺寸 (24x24dp，对于xhdpi可能是48x48，但我们会生成一个通用的)
        # 保持原分辨率通常比较清晰，Android会自动缩放，或者我们可以缩小一点
        # 这里我们保持原比例，但去除多余的透明边距可能更好，不过为了对其，先直接保存
        
        # 确保目录存在
        os.makedirs(os.path.dirname(target_path), exist_ok=True)
        
        img.save(target_path, "PNG")
        print(f"Successfully created {target_path}")
        
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    create_notification_icon()
