import os
import math
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

def cubic_bezier(p0, p1, p2, p3, num_points=100):
    t = np.linspace(0, 1, num_points)[:, None]
    return ((1 - t)**3 * p0 + 
            3 * (1 - t)**2 * t * p1 + 
            3 * (1 - t) * t**2 * p2 + 
            t**3 * p3)

def create_super_canvas(size=2048):
    w, h = size, size
    y_coords, x_coords = np.mgrid[0:h, 0:w]
    
    # Base Obsidian Space: #040D14 -> #071924 -> #02080D
    t = (x_coords / w + y_coords / h) / 2.0
    r = (4 * (1 - t) + 7 * t).astype(np.float32)
    g = (13 * (1 - t) + 25 * t).astype(np.float32)
    b = (20 * (1 - t) + 36 * t).astype(np.float32)
    
    # 1. Cyan Aurora Glow at (0.3w, 0.25h): #00F2FE = (0, 242, 254)
    cx1, cy1 = 0.30 * w, 0.25 * h
    dist1 = np.sqrt((x_coords - cx1)**2 + (y_coords - cy1)**2) / (0.65 * w)
    glow1 = np.clip(1.0 - dist1, 0.0, 1.0) ** 1.9
    r += glow1 * 0 * 0.45
    g += glow1 * 242 * 0.45
    b += glow1 * 254 * 0.45
    
    # 2. Violet Aurora Glow at (0.75w, 0.8h): #8B5CF6 = (139, 92, 246)
    cx2, cy2 = 0.75 * w, 0.80 * h
    dist2 = np.sqrt((x_coords - cx2)**2 + (y_coords - cy2)**2) / (0.70 * w)
    glow2 = np.clip(1.0 - dist2, 0.0, 1.0) ** 2.0
    r += glow2 * 139 * 0.38
    g += glow2 * 92 * 0.38
    b += glow2 * 246 * 0.38
    
    # Clip RGB
    r = np.clip(r, 0, 255).astype(np.uint8)
    g = np.clip(g, 0, 255).astype(np.uint8)
    b = np.clip(b, 0, 255).astype(np.uint8)
    
    rgb = np.stack([r, g, b], axis=-1)
    base_img = Image.fromarray(rgb, 'RGB')
    
    draw = ImageDraw.Draw(base_img, 'RGBA')
    S = size / 1024.0
    
    # --- CANINE PROFILE SILHOUETTE ---
    pts = []
    pts.append([330 * S, 740 * S])
    c1 = cubic_bezier(np.array([330*S, 740*S]), np.array([320*S, 640*S]), np.array([335*S, 530*S]), np.array([380*S, 440*S]), 30)
    pts.extend(c1.tolist())
    c2 = cubic_bezier(np.array([380*S, 440*S]), np.array([415*S, 370*S]), np.array([470*S, 300*S]), np.array([480*S, 230*S]), 30)
    pts.extend(c2.tolist())
    c3 = cubic_bezier(np.array([480*S, 230*S]), np.array([490*S, 200*S]), np.array([515*S, 190*S]), np.array([530*S, 220*S]), 20)
    pts.extend(c3.tolist())
    c4 = cubic_bezier(np.array([530*S, 220*S]), np.array([545*S, 260*S]), np.array([535*S, 320*S]), np.array([580*S, 380*S]), 25)
    pts.extend(c4.tolist())
    c5 = cubic_bezier(np.array([580*S, 380*S]), np.array([620*S, 400*S]), np.array([690*S, 440*S]), np.array([750*S, 510*S]), 30)
    pts.extend(c5.tolist())
    c6 = cubic_bezier(np.array([750*S, 510*S]), np.array([765*S, 540*S]), np.array([735*S, 570*S]), np.array([680*S, 580*S]), 25)
    pts.extend(c6.tolist())
    c7 = cubic_bezier(np.array([680*S, 580*S]), np.array([620*S, 585*S]), np.array([560*S, 610*S]), np.array([520*S, 660*S]), 25)
    pts.extend(c7.tolist())
    pts.append([450 * S, 740 * S])
    
    poly = [(p[0], p[1]) for p in pts]
    
    # Shadow layer
    shadow_layer = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    s_draw = ImageDraw.Draw(shadow_layer)
    s_poly = [(p[0], p[1] + 18 * S) for p in pts]
    s_draw.polygon(s_poly, fill=(0, 0, 0, 130))
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(18 * S))
    base_img.paste(shadow_layer, (0, 0), shadow_layer)
    
    # Canine Body (Frosted Pearl White)
    dog_layer = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    d_draw = ImageDraw.Draw(dog_layer)
    d_draw.polygon(poly, fill=(245, 252, 251, 255))
    base_img.paste(dog_layer, (0, 0), dog_layer)
    
    # Ear Iridescent Facet (Cyan -> Violet)
    ear_pts = []
    e1 = cubic_bezier(np.array([495*S, 235*S]), np.array([515*S, 280*S]), np.array([490*S, 340*S]), np.array([440*S, 395*S]), 25)
    ear_pts.extend(e1.tolist())
    e2 = cubic_bezier(np.array([440*S, 395*S]), np.array([425*S, 360*S]), np.array([430*S, 310*S]), np.array([455*S, 265*S]), 25)
    ear_pts.extend(e2.tolist())
    ear_poly = [(p[0], p[1]) for p in ear_pts]
    
    ear_layer = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    e_draw = ImageDraw.Draw(ear_layer)
    e_draw.polygon(ear_poly, fill=(0, 242, 254, 235)) # Electric Cyan
    base_img.paste(ear_layer, (0, 0), ear_layer)
    
    # Snout Nose Detail
    draw = ImageDraw.Draw(base_img, 'RGBA')
    draw.ellipse([720*S, 520*S, 746*S, 546*S], fill=(7, 35, 34, 255))
    
    # Intelligent Eye
    eye_x, eye_y = 575 * S, 445 * S
    draw.ellipse([eye_x - 14*S, eye_y - 14*S, eye_x + 14*S, eye_y + 14*S], fill=(10, 51, 49, 255))
    draw.ellipse([eye_x - 4*S, eye_y - 4*S, eye_x + 6*S, eye_y + 6*S], fill=(0, 242, 254, 255))
    
    # --- BIOMETRIC TELEMETRY PULSE WAVE ("Vue") ---
    pulse_coords = [
        (220*S, 630*S),
        (320*S, 630*S),
        (355*S, 585*S),
        (395*S, 680*S),
        (445*S, 540*S),
        (495*S, 735*S),
        (545*S, 610*S),
        (580*S, 650*S),
        (630*S, 630*S),
        (800*S, 630*S)
    ]
    
    # Luminous cyan glow behind pulse
    glow_pulse = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    gp_draw = ImageDraw.Draw(glow_pulse)
    for i in range(len(pulse_coords) - 1):
        gp_draw.line([pulse_coords[i], pulse_coords[i+1]], fill=(0, 242, 254, 180), width=int(36 * S))
    glow_pulse = glow_pulse.filter(ImageFilter.GaussianBlur(16 * S))
    base_img.paste(glow_pulse, (0, 0), glow_pulse)
    
    # Crisp pulse line with gradient colors: Cyan -> Aquamarine -> Indigo -> Violet
    pulse_line = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    pl_draw = ImageDraw.Draw(pulse_line)
    
    colors = [
        (0, 242, 254, 255),
        (0, 242, 254, 255),
        (0, 210, 196, 255),
        (56, 189, 248, 255),
        (99, 102, 241, 255),
        (139, 92, 246, 255),
        (99, 102, 241, 255),
        (0, 242, 254, 255),
        (0, 242, 254, 255)
    ]
    for i in range(len(pulse_coords) - 1):
        c = colors[min(i, len(colors)-1)]
        pl_draw.line([pulse_coords[i], pulse_coords[i+1]], fill=c, width=int(18 * S))
        
    for pt in pulse_coords:
        pl_draw.ellipse([pt[0] - 9*S, pt[1] - 9*S, pt[0] + 9*S, pt[1] + 9*S], fill=(0, 242, 254, 255))
        
    base_img.paste(pulse_line, (0, 0), pulse_line)
    
    # Biometric Peak Node: Pearl + Royal Violet
    draw = ImageDraw.Draw(base_img, 'RGBA')
    pk = pulse_coords[5] # 495, 735
    draw.ellipse([pk[0] - 18*S, pk[1] - 18*S, pk[0] + 18*S, pk[1] + 18*S], fill=(255, 255, 255, 255))
    draw.ellipse([pk[0] - 10*S, pk[1] - 10*S, pk[0] + 10*S, pk[1] + 10*S], fill=(139, 92, 246, 255))
    
    pk2 = pulse_coords[4] # 445, 540
    draw.ellipse([pk2[0] - 14*S, pk2[1] - 14*S, pk2[0] + 14*S, pk2[1] + 14*S], fill=(255, 255, 255, 255))
    draw.ellipse([pk2[0] - 8*S, pk2[1] - 8*S, pk2[0] + 8*S, pk2[1] + 8*S], fill=(0, 242, 254, 255))
    
    # Modern Brand Lettering "CANIVUE"
    font_size = int(68 * S)
    try:
        font = ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf", font_size)
    except:
        try:
            font = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", font_size)
        except:
            font = ImageFont.load_default()
            
    text = "CANIVUE"
    spaced_text = "  ".join(list(text))
    bbox = draw.textbbox((0, 0), spaced_text, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    tx = (size - tw) / 2.0
    ty = 845 * S
    draw.text((tx, ty), spaced_text, font=font, fill=(226, 250, 248, 245))
    
    # Glowing Telemetry Beacon Dot
    draw.ellipse([tx + tw + 18*S, ty + th/2 - 6*S, tx + tw + 30*S, ty + th/2 + 6*S], fill=(0, 242, 254, 255))
    
    return base_img

def apply_mask(img, shape='squircle', radius_ratio=0.23):
    w, h = img.size
    mask = Image.new('L', (w, h), 0)
    draw = ImageDraw.Draw(mask)
    if shape == 'round':
        draw.ellipse([0, 0, w, h], fill=255)
    elif shape == 'squircle':
        r = int(w * radius_ratio)
        draw.rounded_rectangle([0, 0, w, h], radius=r, fill=255)
    else:
        return img
    
    result = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    result.paste(img, (0, 0), mask)
    
    # Iridescent liquid glass rim border
    if shape == 'squircle':
        border = Image.new('RGBA', (w, h), (0, 0, 0, 0))
        b_draw = ImageDraw.Draw(border)
        r = int(w * radius_ratio)
        b_draw.rounded_rectangle([2, 2, w-2, h-2], radius=r-2, outline=(0, 242, 254, 180), width=int(max(2, w*0.007)))
        result.alpha_composite(border)
        
    return result

print("Generating Redesigned Liquid Glass Icons...")
raw_2048 = create_super_canvas(2048)

master_1024 = raw_2048.resize((1024, 1024), Image.Resampling.LANCZOS)
master_squircle = apply_mask(master_1024, 'squircle', 0.23)
master_round = apply_mask(master_1024, 'round')

os.makedirs("assets/icons", exist_ok=True)
master_squircle.save("assets/icons/app_icon.png")
master_round.save("assets/icons/app_icon_round.png")
master_1024.save("assets/icons/app_icon_full.png")
print("Saved assets/icons/app_icon.png")

# --- ANDROID ICONS ---
android_res = "android/app/src/main/res"
android_sizes = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192
}

for folder, s in android_sizes.items():
    dir_path = os.path.join(android_res, folder)
    os.makedirs(dir_path, exist_ok=True)
    icon = apply_mask(raw_2048.resize((s, s), Image.Resampling.LANCZOS), 'squircle', 0.23)
    icon.save(os.path.join(dir_path, "ic_launcher.png"))
    icon_round = apply_mask(raw_2048.resize((s, s), Image.Resampling.LANCZOS), 'round')
    icon_round.save(os.path.join(dir_path, "ic_launcher_round.png"))

print("Generated Android icons")

# --- IOS ICONS ---
ios_dir = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
if os.path.exists(ios_dir):
    ios_sizes = {
        "Icon-App-1024x1024@1x.png": 1024,
        "Icon-App-83.5x83.5@2x.png": 167,
        "Icon-App-76x76@2x.png": 152,
        "Icon-App-76x76@1x.png": 76,
        "Icon-App-60x60@3x.png": 180,
        "Icon-App-60x60@2x.png": 120,
        "Icon-App-40x40@3x.png": 120,
        "Icon-App-40x40@2x.png": 80,
        "Icon-App-40x40@1x.png": 40,
        "Icon-App-29x29@3x.png": 87,
        "Icon-App-29x29@2x.png": 58,
        "Icon-App-29x29@1x.png": 29,
        "Icon-App-20x20@3x.png": 60,
        "Icon-App-20x20@2x.png": 40,
        "Icon-App-20x20@1x.png": 20,
    }
    for filename, s in ios_sizes.items():
        icon = master_1024.resize((s, s), Image.Resampling.LANCZOS).convert("RGB")
        icon.save(os.path.join(ios_dir, filename))
    print("Generated iOS icons")

# --- WEB ICONS ---
web_dir = "web"
if os.path.exists(web_dir):
    os.makedirs(os.path.join(web_dir, "icons"), exist_ok=True)
    master_squircle.resize((192, 192), Image.Resampling.LANCZOS).save("web/icons/Icon-192.png")
    master_squircle.resize((512, 512), Image.Resampling.LANCZOS).save("web/icons/Icon-512.png")
    master_1024.resize((192, 192), Image.Resampling.LANCZOS).save("web/icons/Icon-maskable-192.png")
    master_1024.resize((512, 512), Image.Resampling.LANCZOS).save("web/icons/Icon-maskable-512.png")
    master_squircle.resize((32, 32), Image.Resampling.LANCZOS).save("web/favicon.png")
    print("Generated Web icons")

print("All icons successfully updated to Liquid Glass design!")
