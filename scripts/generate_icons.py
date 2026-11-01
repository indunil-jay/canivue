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
    # Create base gradient array
    w, h = size, size
    y_coords, x_coords = np.mgrid[0:h, 0:w]
    
    # Linear gradient: #082825 -> #0D4B45 -> #07221F
    t = (x_coords / w + y_coords / h) / 2.0
    r = (8 * (1 - t) + 13 * t).astype(np.uint8)
    g = (40 * (1 - t) + 75 * t).astype(np.uint8)
    b = (37 * (1 - t) + 69 * t).astype(np.uint8)
    
    # Radial ambient light at (0.5w, 0.35h)
    cx, cy = 0.5 * w, 0.35 * h
    dist = np.sqrt((x_coords - cx)**2 + (y_coords - cy)**2) / (0.7 * w)
    glow = np.clip(1.0 - dist, 0.0, 1.0) ** 1.8
    
    # Add teal glow: #14B8A6 = (20, 184, 166)
    r = np.clip(r + glow * 20 * 0.45, 0, 255).astype(np.uint8)
    g = np.clip(g + glow * 184 * 0.45, 0, 255).astype(np.uint8)
    b = np.clip(b + glow * 166 * 0.45, 0, 255).astype(np.uint8)
    
    rgb = np.stack([r, g, b], axis=-1)
    base_img = Image.fromarray(rgb, 'RGB')
    
    # Draw elements
    draw = ImageDraw.Draw(base_img, 'RGBA')
    
    # Scale factor from 1024 to `size`
    S = size / 1024.0
    
    # --- CANINE PROFILE SILHOUETTE ---
    # Construct smooth polygon points for the modern dog head
    pts = []
    # Base neck
    pts.append([330 * S, 740 * S])
    # Left back curve: 330,740 -> 320,640 -> 335,530 -> 380,440
    c1 = cubic_bezier(np.array([330*S, 740*S]), np.array([320*S, 640*S]), np.array([335*S, 530*S]), np.array([380*S, 440*S]), 30)
    pts.extend(c1.tolist())
    # Neck to ear curve: 380,440 -> 415,370 -> 470,300 -> 480,230
    c2 = cubic_bezier(np.array([380*S, 440*S]), np.array([415*S, 370*S]), np.array([470*S, 300*S]), np.array([480*S, 230*S]), 30)
    pts.extend(c2.tolist())
    # Ear tip curve: 480,230 -> 490,200 -> 515,190 -> 530,220
    c3 = cubic_bezier(np.array([480*S, 230*S]), np.array([490*S, 200*S]), np.array([515*S, 190*S]), np.array([530*S, 220*S]), 20)
    pts.extend(c3.tolist())
    # Ear down to forehead: 530,220 -> 545,260 -> 535,320 -> 580,380
    c4 = cubic_bezier(np.array([530*S, 220*S]), np.array([545*S, 260*S]), np.array([535*S, 320*S]), np.array([580*S, 380*S]), 25)
    pts.extend(c4.tolist())
    # Forehead to muzzle snout: 580,380 -> 620,400 -> 690,440 -> 750,510
    c5 = cubic_bezier(np.array([580*S, 380*S]), np.array([620*S, 400*S]), np.array([690*S, 440*S]), np.array([750*S, 510*S]), 30)
    pts.extend(c5.tolist())
    # Snout tip to jaw: 750,510 -> 765,540 -> 735,570 -> 680,580
    c6 = cubic_bezier(np.array([750*S, 510*S]), np.array([765*S, 540*S]), np.array([735*S, 570*S]), np.array([680*S, 580*S]), 25)
    pts.extend(c6.tolist())
    # Jaw to neck: 680,580 -> 620,585 -> 560,610 -> 520,660
    c7 = cubic_bezier(np.array([680*S, 580*S]), np.array([620*S, 585*S]), np.array([560*S, 610*S]), np.array([520*S, 660*S]), 25)
    pts.extend(c7.tolist())
    # Down to base: 520,660 -> 480,710 -> 450,740
    pts.append([450 * S, 740 * S])
    
    poly = [(p[0], p[1]) for p in pts]
    
    # Shadow layer for dog head
    shadow_layer = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    s_draw = ImageDraw.Draw(shadow_layer)
    s_poly = [(p[0], p[1] + 16 * S) for p in pts]
    s_draw.polygon(s_poly, fill=(0, 0, 0, 110))
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(16 * S))
    base_img.paste(shadow_layer, (0, 0), shadow_layer)
    
    # Draw body polygon with crisp clean gradient off-white / mint tint
    dog_layer = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    d_draw = ImageDraw.Draw(dog_layer)
    d_draw.polygon(poly, fill=(244, 252, 250, 255))
    base_img.paste(dog_layer, (0, 0), dog_layer)
    
    # Draw Ear geometric inner facet (Teal Accent)
    ear_pts = []
    e1 = cubic_bezier(np.array([495*S, 235*S]), np.array([515*S, 280*S]), np.array([490*S, 340*S]), np.array([440*S, 395*S]), 25)
    ear_pts.extend(e1.tolist())
    e2 = cubic_bezier(np.array([440*S, 395*S]), np.array([425*S, 360*S]), np.array([430*S, 310*S]), np.array([455*S, 265*S]), 25)
    ear_pts.extend(e2.tolist())
    ear_poly = [(p[0], p[1]) for p in ear_pts]
    
    ear_layer = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    e_draw = ImageDraw.Draw(ear_layer)
    e_draw.polygon(ear_poly, fill=(45, 212, 191, 230)) # #2DD4BF
    base_img.paste(ear_layer, (0, 0), ear_layer)
    
    # Snout Nose Detail
    draw = ImageDraw.Draw(base_img, 'RGBA')
    draw.ellipse([720*S, 520*S, 746*S, 546*S], fill=(13, 92, 84, 255))
    
    # Intelligent Eye (Deep teal + glowing cyan spark)
    eye_x, eye_y = 575 * S, 445 * S
    draw.ellipse([eye_x - 14*S, eye_y - 14*S, eye_x + 14*S, eye_y + 14*S], fill=(15, 118, 110, 255))
    draw.ellipse([eye_x - 4*S, eye_y - 4*S, eye_x + 6*S, eye_y + 6*S], fill=(94, 234, 212, 255))
    
    # --- BIOMETRIC / VITALS PULSE WAVE ("Vue") ---
    # Points across chest/neck in dynamic V formation
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
    
    # Glow behind pulse line
    glow_pulse = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    gp_draw = ImageDraw.Draw(glow_pulse)
    for i in range(len(pulse_coords) - 1):
        gp_draw.line([pulse_coords[i], pulse_coords[i+1]], fill=(45, 212, 191, 160), width=int(32 * S))
    glow_pulse = glow_pulse.filter(ImageFilter.GaussianBlur(14 * S))
    base_img.paste(glow_pulse, (0, 0), glow_pulse)
    
    # Crisp pulse line
    pulse_line = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    pl_draw = ImageDraw.Draw(pulse_line)
    
    # Color transitions from #2DD4BF -> #38BDF8 -> #818CF8
    colors = [
        (45, 212, 191, 255),
        (45, 212, 191, 255),
        (56, 189, 248, 255),
        (56, 189, 248, 255),
        (99, 102, 241, 255),
        (129, 140, 248, 255),
        (56, 189, 248, 255),
        (45, 212, 191, 255),
        (45, 212, 191, 255)
    ]
    for i in range(len(pulse_coords) - 1):
        c = colors[min(i, len(colors)-1)]
        pl_draw.line([pulse_coords[i], pulse_coords[i+1]], fill=c, width=int(18 * S))
        
    # Draw rounded joints
    for pt in pulse_coords:
        pl_draw.ellipse([pt[0] - 9*S, pt[1] - 9*S, pt[0] + 9*S, pt[1] + 9*S], fill=(45, 212, 191, 255))
        
    base_img.paste(pulse_line, (0, 0), pulse_line)
    
    # Biometric Vital Peak Node
    draw = ImageDraw.Draw(base_img, 'RGBA')
    pk = pulse_coords[5] # 495, 735
    draw.ellipse([pk[0] - 18*S, pk[1] - 18*S, pk[0] + 18*S, pk[1] + 18*S], fill=(255, 255, 255, 255))
    draw.ellipse([pk[0] - 10*S, pk[1] - 10*S, pk[0] + 10*S, pk[1] + 10*S], fill=(99, 102, 241, 255))
    
    pk2 = pulse_coords[4] # 445, 540
    draw.ellipse([pk2[0] - 14*S, pk2[1] - 14*S, pk2[0] + 14*S, pk2[1] + 14*S], fill=(255, 255, 255, 255))
    draw.ellipse([pk2[0] - 8*S, pk2[1] - 8*S, pk2[0] + 8*S, pk2[1] + 8*S], fill=(45, 212, 191, 255))
    
    # Modern Brand Lettering "CANIVUE" at lower portion
    # Try default sans or font
    font_size = int(68 * S)
    try:
        font = ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf", font_size)
    except:
        try:
            font = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", font_size)
        except:
            font = ImageFont.load_default()
            
    text = "CANIVUE"
    # Spaced characters for modern luxury look
    spaced_text = "  ".join(list(text))
    bbox = draw.textbbox((0, 0), spaced_text, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    tx = (size - tw) / 2.0
    ty = 845 * S
    draw.text((tx, ty), spaced_text, font=font, fill=(167, 243, 208, 240))
    
    # Glowing sensor dot next to Vue
    draw.ellipse([tx + tw + 18*S, ty + th/2 - 6*S, tx + tw + 30*S, ty + th/2 + 6*S], fill=(56, 189, 248, 255))
    
    return base_img

def apply_mask(img, shape='squircle', radius_ratio=0.22):
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
    
    # Add subtle border highlight on the squircle
    result = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    result.paste(img, (0, 0), mask)
    
    if shape == 'squircle':
        border = Image.new('RGBA', (w, h), (0, 0, 0, 0))
        b_draw = ImageDraw.Draw(border)
        b_draw.rounded_rectangle([2, 2, w-2, h-2], radius=int(w*radius_ratio)-2, outline=(45, 212, 191, 70), width=int(max(2, w*0.005)))
        result.alpha_composite(border)
        
    return result

print("Generating Master Icons...")
raw_2048 = create_super_canvas(2048)

# Master 1024x1024 squircle (iOS / standard / Web)
master_1024 = raw_2048.resize((1024, 1024), Image.Resampling.LANCZOS)
master_squircle = apply_mask(master_1024, 'squircle', 0.22)
master_round = apply_mask(master_1024, 'round')

# Save Master to assets
os.makedirs("assets/icons", exist_ok=True)
master_squircle.save("assets/icons/app_icon.png")
master_round.save("assets/icons/app_icon_round.png")
# Full bleed for Android adaptive icon background & foreground
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
    # Standard icon (with squircle mask)
    icon = apply_mask(raw_2048.resize((s, s), Image.Resampling.LANCZOS), 'squircle', 0.22)
    icon.save(os.path.join(dir_path, "ic_launcher.png"))
    # Round icon (for Pixel & modern launchers)
    icon_round = apply_mask(raw_2048.resize((s, s), Image.Resampling.LANCZOS), 'round')
    icon_round.save(os.path.join(dir_path, "ic_launcher_round.png"))
    print(f"Generated Android {folder} ({s}x{s})")

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
        # iOS expects square without alpha mask (iOS system clips with continuous curvature squircle)
        icon = master_1024.resize((s, s), Image.Resampling.LANCZOS).convert("RGB")
        icon.save(os.path.join(ios_dir, filename))
        print(f"Generated iOS {filename} ({s}x{s})")

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

print("All icons successfully generated!")
