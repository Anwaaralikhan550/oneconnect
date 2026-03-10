# Figma Design Spacing Analysis - General Store Screen

## Node ID: 1952-8523 (General Store)

---

## 1. HERO SECTION (Node: 1952:8678)

**Container Properties:**
- Layout: Vertical column with vertical scroll
- Gap between child sections: **10px**
- Padding: **10px 0px**
- Height: **623px** (fixed)
- Align: stretch (fills width)

### Child Sections within Hero (in order):

#### 1.1 Business Hours Section (Frame 377 - Node: 2463:5371)
- **Padding:** 15px 25px
- **Width:** 360px (fixed)
- **Border:** 2px solid #F3F3F3
- **Border Radius:** 15px
- **Gap before next section:** 10px

#### 1.2 Location Section (Frame 381 - Node: 2463:5375)
- **Padding:** 15px 25px
- **Width:** 360px (fixed)
- **Background:** #F4F4F4
- **Border Radius:** 15px
- **Gap before this section:** 10px
- **Gap after this section:** 10px

#### 1.3 Contact Section (Frame 386 - Node: 2463:5380)
- **Padding:** 15px 0px
- **Width:** 360px (fixed)
- **Border:** 2px solid #F3F3F3
- **Border Radius:** 15px
- **Gap:** 60px (internal gap between phone and WhatsApp)
- **Gap before this section:** 10px
- **Gap after this section:** 10px

---

## 2. SERVICES OFFERED SECTION (Node: 2463:5381)

**Complete Spacing Details:**
- **Padding (Container):** 10px 0px (top/bottom), 0px (left/right)
- **Border:** 1px 0px 0px (top border only) - Color: #D2D2D2
- **Gap before this section:** 10px (from Hero section)
- **Gap after this section:** 10px (to Review Us section)

**Internal Structure:**
1. **Title Frame (Frame 401 - Node: 2463:5395):**
   - Padding: 10px 20px
   - Gradient background (gray to white)
   - Contains: "Services Offered" text

2. **Services Grid (Frame 398 - Node: 2463:5392):**
   - Padding: 10px 25px
   - Gap between left and right columns: **45px**
   - Gap within columns: **10px**
   - Layout: 2 columns with 2 rows each

**Internal Gap:** 10px (between title and services grid)

---

## 3. REVIEW US SECTION (Node: 3082:8548)

**Complete Spacing Details:**
- **Padding:** 15px 0px
- **Gap:** 20px (between avatar/stars and button)
- **Border:** 1px 0px (top and bottom borders) - Color: #E3E3E3
- **Background:** #FAFAFA
- **Gap before this section:** 10px
- **Gap after this section:** 10px

---

## 4. PROMOTIONS/SPECIAL OFFERS SECTION (Node: 2463:5394)

**Complete Spacing Details:**
- **Padding (Container):** 10px 0px
- **Width:** 390px (fixed)
- **Gap before this section:** 10px
- **Gap after this section:** 10px

**Internal Structure:**
1. **Title Section (Node: 3083:8569):**
   - Padding: 0px 25px
   - Width: 390px
   - Contains icon + "Special offers for you" text

2. **Offers Carousel (Node: 1952:8722):**
   - Padding: 0px 15px
   - Horizontal scroll enabled
   - Gap between carousel items: **15px**
   - Background: #FFFFFF

**Internal Gap (Title to Carousel):** 10px

---

## 5. PHOTOS FRAME SECTION (Node: 2897:10484)

**Complete Spacing Details:**
- **Padding:** 10px 0px
- **Height:** 234px (fixed)
- **Gap before this section:** 10px
- **Gap after this section:** 10px

**Internal Structure:**
1. **Title (Frame 113 - Node: 2897:10485):**
   - Padding: 0px 20px
   - Contains: "Photos and Videos" text

2. **Photo Accordion Component:**
   - Gap between photos: **25px**
   - Contains carousel bars with **8px** gap

**Internal Gap (Title to Photos):** 15px

---

## 6. REVIEWS SECTION (Node: 2464:5396)

**Complete Spacing Details:**
- **Padding:** 10px 0px
- **Gap before this section:** 10px

**Internal Structure:**
1. **Title (Customer Reviews):**
   - Padding: 0px 20px

2. **Review Cards:**
   - Padding per card: 10px
   - Width: 344px
   - Gap between review cards: **15px**
   - Border Radius: 15px
   - First review has shadow effect

**Internal Gap (Title to Reviews):** 15px

---

## COMPLETE VERTICAL SPACING FLOW

From top to bottom, here's the exact flow with all gaps:

```
General Store Container (390x844)
├─ Padding Top: 55px
├─ Gap: 15px
│
├─ Profile Section (padding: 5px 0px, gap: 8px)
│
├─ Gap: 15px
│
├─ HEADER Section
│
├─ Gap: 15px
│
├─ Frame 404 (ID Badge area, gap: 20px)
│
├─ Gap: 15px
│
└─ HERO SECTION (height: 623px, scroll container)
    │
    ├─ Padding Top: 10px (implicit from gap)
    │
    ├─ Business Hours (Frame 377)
    │   └─ Padding: 15px 25px
    │
    ├─ Gap: 10px
    │
    ├─ Location (Frame 381)
    │   └─ Padding: 15px 25px
    │
    ├─ Gap: 10px
    │
    ├─ Contact (Frame 386)
    │   └─ Padding: 15px 0px
    │   └─ Internal gap: 60px (between phone/WhatsApp sections)
    │
    ├─ Gap: 10px
    │
    ├─ Services Offered (Frame 387)
    │   ├─ Padding: 10px 0px
    │   ├─ Title padding: 10px 20px
    │   ├─ Internal gap: 10px (title to grid)
    │   └─ Services grid padding: 10px 25px
    │       └─ Column gap: 45px
    │
    ├─ Gap: 10px
    │
    ├─ Review Us Section
    │   ├─ Padding: 15px 0px
    │   └─ Internal gap: 20px
    │
    ├─ Gap: 10px
    │
    ├─ Promotions (Special Offers)
    │   ├─ Padding: 10px 0px
    │   ├─ Title padding: 0px 25px
    │   ├─ Internal gap: 10px (title to carousel)
    │   └─ Carousel padding: 0px 15px
    │       └─ Item gap: 15px
    │
    ├─ Gap: 10px
    │
    ├─ Photos Frame
    │   ├─ Padding: 10px 0px
    │   ├─ Title padding: 0px 20px
    │   ├─ Internal gap: 15px (title to photos)
    │   └─ Photos gap: 25px
    │
    ├─ Gap: 10px
    │
    └─ Reviews Section
        ├─ Padding: 10px 0px
        ├─ Title padding: 0px 20px
        ├─ Internal gap: 15px (title to reviews)
        └─ Review cards gap: 15px
```

---

## KEY SPACING VALUES SUMMARY

### Main Container:
- **Top padding:** 55px
- **Main section gaps:** 15px (between major sections)
- **Hero section height:** 623px (scrollable)

### Hero Section (Vertical Spacing):
- **Gap between all sections:** 10px (consistent)
- **Container padding:** 10px 0px

### Section-Specific Padding:
- **Business Hours:** 15px 25px
- **Location:** 15px 25px
- **Contact:** 15px 0px
- **Services Offered:** 10px 0px (container), 10px 20px (title), 10px 25px (grid)
- **Review Us:** 15px 0px
- **Promotions:** 10px 0px (container), 0px 25px (title), 0px 15px (carousel)
- **Photos:** 10px 0px (container), 0px 20px (title)
- **Reviews:** 10px 0px (container), 0px 20px (title)

### Internal Gaps:
- **Services grid columns:** 45px
- **Contact sections:** 60px
- **Review Us content:** 20px
- **Promotions carousel items:** 15px
- **Photos carousel items:** 25px
- **Review cards:** 15px
- **Title to content (Photos/Reviews):** 15px
- **Title to content (Services/Promotions):** 10px

### Border Styles:
- **Business Hours/Contact:** 2px solid #F3F3F3
- **Services Offered:** 1px 0px 0px #D2D2D2 (top only)
- **Review Us:** 1px 0px #E3E3E3 (top and bottom)

### Border Radius:
- **Most sections:** 15px
- **Photos carousel:** 20px
