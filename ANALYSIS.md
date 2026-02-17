# Yoshlar Nazorati - Loyihaning To'liq Tahlili (v3)

## 1. Loyiha Haqida Umumiy Ma'lumot

**Nomi:** Yoshlar Nazorati (yoshlarnazorat)
**Turi:** Flutter mobil/web ilovasi + Laravel REST API backend
**Maqsadi:** Jizzax viloyatidagi xavf guruhiga kiruvchi yoshlarni nazorat qilish, ular bilan ishlash jarayonlarini boshqarish va mas'ul xodimlarni tayinlash tizimi.
**Flutter SDK:** ^3.10.4
**Laravel:** 12 (Sanctum autentifikatsiya)
**Ma'lumotlar bazasi:** MySQL (yoshlar_nazorat, root/jdpu)
**Versiya:** 1.0.0+1
**Dart fayllari:** 54 ta (476KB)
**Backend PHP fayllari:** ~40 ta

---

## 2. Texnologiyalar va Kutubxonalar

### 2.1 Frontend (Flutter)

| Kutubxona | Versiya | Vazifasi | Holati |
|---|---|---|---|
| `go_router` | ^17.0.1 | Navigatsiya va marshrut boshqaruvi | Ishlatilmoqda |
| `flutter_bloc` / `bloc` | ^9.1.1 / ^9.2.0 | State management (Cubit) | Ishlatilmoqda |
| `http` / `http_parser` | ^1.6.0 / ^4.1.2 | API so'rovlari | Ishlatilmoqda |
| `fl_chart` | ^0.70.0 | Diagramma va grafiklar | Ishlatilmoqda |
| `image_picker` | ^1.0.7 | Rasm tanlash (kamera/galereya) | Ishlatilmoqda |
| `fluttertoast` | ^8.2.4 | Toast xabarlar | Ishlatilmoqda |
| `shared_preferences` | ^2.5.0 | Token saqlash | Ishlatilmoqda |
| `geolocator` | ^13.0.2 | Geolokatsiya xizmati | Ishlatilmoqda |
| `equatable` | ^2.0.8 | Ob'yektlarni taqqoslash (BLoC uchun) | Ishlatilmoqda |
| `flutter_staggered_animations` | ^1.1.1 | Animatsiyalar | Ishlatilmoqda |
| `easy_search_bar_2` | ^1.0.0 | Qidiruv paneli | Ishlatilmoqda |
| `permission_handler` | ^12.0.1 | Ruxsatlarni boshqarish | Ishlatilmoqda |
| `url_launcher` | ^6.2.5 | URL ochish (Google Maps) | Ishlatilmoqda |
| `web` | ^1.1.0 | Web qo'llab-quvvatlash | Ishlatilmoqda |
| `shimmer` | ^3.0.0 | Yuklash animatsiyasi | Ishlatilmagan |
| `google_nav_bar` | ^5.0.7 | Pastki navigatsiya | Ishlatilmagan |

### 2.2 Backend (Laravel)

| Texnologiya | Versiya | Vazifasi |
|---|---|---|
| Laravel | ^12.0 | PHP framework |
| Sanctum | ^4.0 | API token autentifikatsiya |
| MySQL | 8.x | Ma'lumotlar bazasi |
| Eloquent ORM | - | Ma'lumotlar modellari |
| Form Requests | - | Validatsiya |
| JSON Resources | - | API javob formatlash |
| Tinker | ^2.10.1 | Debug/REPL |

---

## 3. Loyiha Arxitekturasi

### 3.1 Umumiy Tuzilish

```
yoshlarnazorat-main/
├── lib/                          # Flutter frontend (54 Dart fayl)
│   ├── main.dart                 # Ilovaning kirish nuqtasi
│   ├── router/                   # GoRouter navigatsiya
│   │   └── app_router.dart
│   ├── data/                     # Data layer (16 fayl)
│   │   ├── model/                # Ma'lumot modellari (8 ta)
│   │   │   ├── auth_user.dart
│   │   │   ├── user.dart         # Youth model
│   │   │   ├── activity.dart     # Activity + ActivityImage
│   │   │   ├── officer.dart
│   │   │   ├── category.dart
│   │   │   ├── region.dart
│   │   │   ├── comment.dart
│   │   │   └── dashboard_stats.dart
│   │   └── service/              # API xizmatlari (8 ta)
│   │       ├── api_client.dart
│   │       ├── auth_service.dart
│   │       ├── youth_service.dart
│   │       ├── activity_service.dart
│   │       ├── officer_service.dart
│   │       ├── dashboard_service.dart
│   │       ├── face_compare_service.dart
│   │       └── location_service.dart
│   ├── logic/                    # Business logic layer (12 fayl)
│   │   ├── auth/                 # AuthCubit + State
│   │   ├── youth/                # YouthListCubit, YouthDetailCubit + States
│   │   ├── activity/             # ActivityListCubit + State
│   │   ├── dashboard/            # DashboardCubit + State
│   │   └── officer/              # OfficerCubit + State
│   └── presentation/             # UI layer (23 fayl, 18 papka)
│       ├── splash/               # Splash ekran
│       ├── auth/                 # Login sahifasi + widgets
│       ├── yoshlar/              # Mas'ul xodim paneli
│       │   ├── main/             # Bosh ekran + widgets
│       │   │   ├── main_item_screen.dart/  # Tarix ekranlari
│       │   │   └── add_activity/ # Faoliyat qo'shish
│       │   └── profile/          # Profil sozlamalari
│       ├── nazorat/              # Rahbariyat paneli
│       │   ├── main/             # Dashboard + diagrammalar
│       │   ├── yoshlar/          # Yoshlar CRUD
│       │   ├── masullar/         # Mas'ullar boshqaruvi
│       │   └── jarayonlar/       # Jarayonlar ro'yxati
│       └── widgets/              # Umumiy widgetlar
│           └── web_camera_dialog.dart
│
└── backend/                      # Laravel backend
    ├── app/
    │   ├── Http/
    │   │   ├── Controllers/Api/  # 8 ta controller
    │   │   ├── Middleware/        # 2 ta (EnsureMasul, EnsureRahbariyat)
    │   │   ├── Requests/         # 8 ta form request
    │   │   └── Resources/        # 8 ta JSON resource
    │   ├── Models/               # 8 ta Eloquent model
    │   └── Services/             # CredentialGenerator
    ├── database/
    │   ├── migrations/           # 13 ta migratsiya
    │   └── seeders/              # 7 ta seeder
    ├── bootstrap/
    │   └── app.php               # Middleware + Exception handler
    ├── config/
    │   ├── sanctum.php           # Token: 24 soat
    │   ├── cors.php              # localhost:3000, :8080
    │   └── auth.php              # Eloquent driver
    └── routes/
        └── api.php               # API marshrutlari (30+ endpoint)
```

### 3.2 Arxitektura Pattern

```
Presentation Layer (23 fayl - ekranlar va widgetlar)
        ↓ (BlocBuilder/BlocListener)
Business Logic Layer (12 fayl - Cubitlar va Statelar)
        ↓ (Service chaqiruvlari)
Data Layer (16 fayl - Servicelar va Modellar)
        ↓ (HTTP so'rovlar)
Backend API (Laravel - localhost:8000, 30+ endpoint)
        ↓ (Eloquent ORM)
MySQL Database (yoshlar_nazorat)
```

### 3.3 Ikki Rolli Tizim

| Rol | Backend nomi | Ruxsatlar |
|---|---|---|
| **Mas'ul xodim** | `masul` | O'z yoshlarini ko'rish, faoliyat qo'shish, rasm yuklash, yosh rasmini o'zgartirish |
| **Rahbariyat** | `rahbariyat` | Dashboard, yoshlar CRUD, mas'ullar CRUD, biriktirish, barcha jarayonlarni ko'rish |

---

## 4. Ma'lumotlar Bazasi Sxemasi

### 4.1 Jadvallar

```
users
├── id, name, username (unique), email (unique), phone
├── role (enum: masul|rahbariyat), password (hashed cast)
├── Has one: Officer
└── Has many: Comments

regions (13 ta Jizzax tumanlari)
├── id, name, timestamps
├── Has many: Officers
└── Has many: Youths

categories (8 ta toifa)
├── id, name, description, timestamps
└── Many-to-many: Youths (youth_category)

officers (5 demo)
├── id, user_id (nullable FK), full_name, position
├── region_id (FK cascade), phone, photo, timestamps
├── Belongs to: User (nullable), Region
├── Many-to-many: Youths (youth_officer)
└── Has many: Activities

youths (20 demo)
├── id, full_name, photo, birth_date (date cast), gender
├── address, region_id (FK cascade)
├── education_status, employment_status, risk_level, description
├── Belongs to: Region
├── Many-to-many: Categories, Officers
└── Has many: Activities

activities (20-60 demo)
├── id, youth_id (FK cascade), officer_id (nullable FK)
├── title, description, result
├── date (date cast), status (enum: bajarilgan|rejalashtirilgan)
├── latitude, longitude, timestamps
├── Belongs to: Youth, Officer (nullable)
├── Has many: ActivityImages, Comments
└── Cascade: youth o'chirilsa, activities ham o'chiriladi

activity_images
├── id, activity_id (FK cascade), path, timestamps
└── Belongs to: Activity

comments
├── id, activity_id (FK cascade), user_id (FK cascade)
├── body, timestamps
└── Belongs to: Activity, User

personal_access_tokens (Sanctum)
└── Token muddati: 24 soat
```

### 4.2 Bog'lanishlar Diagrammasi

```
users (1) ──→ (1) officers ──→ (N) activities
  │                  ↕                 │
  │           youth_officer            │
  │                  ↕                 │
  └── comments ←── activities ──→ activity_images
                       │
                    youths ──→ regions
                       ↕
                youth_category ←→ categories
```

### 4.3 Cascade Qoidalari

| Bog'lanish | Qoida |
|---|---|
| youth → activities | cascadeOnDelete |
| youth → youth_category | cascadeOnDelete |
| youth → youth_officer | cascadeOnDelete |
| officer → youth_officer | cascadeOnDelete |
| officer → activities | nullOnDelete |
| user → officers | nullOnDelete |
| user → comments | cascadeOnDelete |
| activity → activity_images | cascadeOnDelete |
| activity → comments | cascadeOnDelete |

---

## 5. API Endpointlar

### 5.1 Autentifikatsiya

| Metod | Endpoint | Vazifasi | Himoya |
|---|---|---|---|
| POST | `/api/auth/login` | Tizimga kirish (username/password) | Ochiq |
| POST | `/api/auth/logout` | Tizimdan chiqish | auth:sanctum |
| GET | `/api/auth/me` | Joriy foydalanuvchi | auth:sanctum |
| PUT | `/api/auth/profile` | Profil yangilash (username/password) | auth:sanctum |

### 5.2 Yoshlar

| Metod | Endpoint | Vazifasi | Himoya |
|---|---|---|---|
| GET | `/api/youths` | Ro'yxat (filter, search, pagination 20) | auth:sanctum |
| GET | `/api/youths/{id}` | Bitta yosh ma'lumoti | auth:sanctum |
| POST | `/api/youths` | Yangi yosh qo'shish (+ rasm) | rahbariyat |
| POST | `/api/youths/{id}` | Yosh ma'lumotini yangilash (+ rasm) | rahbariyat |
| DELETE | `/api/youths/{id}` | Yosh o'chirish | rahbariyat |
| POST | `/api/youths/{id}/photo` | Yosh rasmini o'zgartirish | masul |

**Filter parametrlari:** `?region=1&gender=Erkak&category=1&officer_id=2&search=Azizbek&page=1`

### 5.3 Faoliyatlar

| Metod | Endpoint | Vazifasi | Himoya |
|---|---|---|---|
| GET | `/api/activities` | Barcha faoliyatlar (pagination 20, officer filter) | rahbariyat |
| GET | `/api/youths/{id}/activities` | Yosh faoliyatlari | auth:sanctum |
| POST | `/api/youths/{id}/activities` | Faoliyat qo'shish (auto officer_id) | masul |
| GET | `/api/activities/{id}` | Faoliyat tafsilotlari | auth:sanctum |
| POST | `/api/activities/{id}/images` | Rasm yuklash (3-10, max 5MB) | masul |

### 5.4 Izohlar

| Metod | Endpoint | Vazifasi | Himoya |
|---|---|---|---|
| GET | `/api/activities/{id}/comments` | Izohlar ro'yxati | auth:sanctum |
| POST | `/api/activities/{id}/comments` | Izoh qo'shish | auth:sanctum |

### 5.5 Mas'ullar

| Metod | Endpoint | Vazifasi | Himoya |
|---|---|---|---|
| GET | `/api/officers` | Mas'ullar ro'yxati | auth:sanctum |
| GET | `/api/officers/{id}` | Mas'ul ma'lumoti | auth:sanctum |
| POST | `/api/officers` | Yangi mas'ul qo'shish | rahbariyat |
| POST | `/api/officers/{id}` | Mas'ul tahrirlash | rahbariyat |
| DELETE | `/api/officers/{id}` | Mas'ul o'chirish | rahbariyat |
| GET | `/api/officers/{id}/youths` | Mas'ul yoshlari | auth:sanctum |
| POST | `/api/officers/{id}/attach-youths` | Yoshlarni biriktirish | rahbariyat |
| POST | `/api/officers/{id}/detach-youths` | Yoshlarni ajratish | rahbariyat |
| POST | `/api/officers/{id}/generate-credentials` | Login yaratish | rahbariyat |
| POST | `/api/officers/{id}/reset-password` | Parol tiklash | rahbariyat |

### 5.6 Dashboard va Ma'lumotnomalar

| Metod | Endpoint | Vazifasi | Himoya |
|---|---|---|---|
| GET | `/api/dashboard/stats` | Statistika (jami, jins) | rahbariyat |
| GET | `/api/dashboard/regions` | Hududlar statistikasi | rahbariyat |
| GET | `/api/dashboard/categories` | Toifalar statistikasi | rahbariyat |
| GET | `/api/categories` | Barcha toifalar | auth:sanctum |
| GET | `/api/regions` | Barcha hududlar | auth:sanctum |

### 5.7 Yuz solishtirish

| Metod | Endpoint | Vazifasi | Himoya |
|---|---|---|---|
| POST | `/api/face-compare` | Selfie va officer rasmini solishtirish | auth:sanctum |

### 5.8 API Javob Formati

```json
// Muvaffaqiyatli javob (collection)
{
  "data": [ ... ],
  "links": { "first": "...", "last": "...", "prev": null, "next": "..." },
  "meta": { "current_page": 1, "last_page": 3, "per_page": 20, "total": 54 }
}

// Muvaffaqiyatli javob (single)
{ "data": { ... } }

// Xatolik javob
{ "message": "Xatolik tavsifi", "errors": { ... } }
```

---

## 6. Frontend Ma'lumot Modellari va Xizmatlari

### 6.1 Dart Modellari (8 ta)

| Model | Fayl | Asosiy Maydonlar |
|---|---|---|
| **AuthUser** | `auth_user.dart` | id, name, username, email, phone, role, officerId, officerPhoto |
| **UserModel** (Youth) | `user.dart` | id, name, image, birthDate, gender, location, region, regionId, status, activity, riskLevel, tags, categories, officers, activitiesCount, description |
| **Activity** | `activity.dart` | id, youthId, youthName, officer, title, description, result, date, status, images, commentsCount, latitude, longitude, createdAt, `dateWithTime` (getter) |
| **ActivityImage** | `activity.dart` | id, url |
| **OfficerModel** | `officer.dart` | id, userId, fullName, position, region, regionId, phone, photo, youthsCount |
| **RegionModel** | `region.dart` | id, name, youthsCount |
| **CategoryModel** | `category.dart` | id, name, description, youthsCount |
| **Comment** | `comment.dart` | id, body, user (CommentUser), createdAt |
| **DashboardStats** | `dashboard_stats.dart` | jamiYoshlar, ogilBolalar, qizBolalar |

### 6.2 API Xizmatlari (8 ta)

| Xizmat | Fayl | Asosiy Metodlari |
|---|---|---|
| **ApiClient** | `api_client.dart` | get, post, put, patch, delete, multipartPost, multipartPostWithBytes, multipartPostWithBytesList |
| **AuthService** | `auth_service.dart` | login, logout, me, updateProfile |
| **YouthService** | `youth_service.dart` | getYouths (filter/pagination/officerId), getYouth, createYouth (+imageBytes), updateYouth (+imageBytes), updateYouthPhoto, deleteYouth |
| **ActivityService** | `activity_service.dart` | getAllActivities (pagination/officerFilter), getYouthActivities, createActivity, getActivity, uploadImages, getComments, addComment |
| **OfficerService** | `officer_service.dart` | getOfficers, getOfficer, createOfficer, updateOfficer, getOfficerYouths, attachYouths, detachYouths, generateCredentials, resetPassword |
| **DashboardService** | `dashboard_service.dart` | getStats, getRegions, getCategories |
| **LocationService** | `location_service.dart` | getCurrentPosition (Geolocator, medium accuracy, 5s timeout) |
| **FaceCompareService** | `face_compare_service.dart` | compareFace (70% threshold) |

**Base URL:** `http://localhost:8000/api`
**Storage URL:** `http://localhost:8000/storage`

### 6.3 State Management (6 ta Cubit)

| Cubit | Fayl | Statelar | Vazifasi |
|---|---|---|---|
| **AuthCubit** | `auth_cubit.dart` | Initial, Loading, Authenticated, Unauthenticated, Error | Login, logout, auth tekshirish, profil yangilash, forceLogout (401) |
| **YouthListCubit** | `youth_list_cubit.dart` | Initial, Loading, Loaded (pagination, copyWith), Error | Ro'yxat, filter (region/gender/officer), search, pagination, CRUD |
| **YouthDetailCubit** | `youth_detail_cubit.dart` | Loading, Loaded (youth + activities), Error | Tafsilotlar, faoliyat yaratish |
| **ActivityListCubit** | `activity_list_cubit.dart` | Loading, Loaded (pagination, copyWith), Error | Barcha faoliyatlar, officer filter, pagination |
| **DashboardCubit** | `dashboard_cubit.dart` | Loading, Loaded, Error | Statistika, hududlar, toifalar (parallel yuklash) |
| **OfficerCubit** | `officer_cubit.dart` | Initial, Loading, ListLoaded, YouthsLoaded, Error | Mas'ullar CRUD, yoshlar biriktirish/ajratish |

---

## 7. Navigatsiya Tuzilishi (GoRouter v17)

```
/ (SplashPage) - 2 soniya, auth tekshirish
├── /login (LoginPage) - Username/parol
│
├── /main (MainScreen - Mas'ul paneli)
│   ├── O'z yoshlari ro'yxati (qidiruv bilan)
│   ├── Profil kartochkasi (rasm, ism, lavozim)
│   ├── Yoshga rasm yuklash tugmasi
│   ├── main/profile → ProfileScreen (username/parol o'zgartirish)
│   ├── main/edit_youth → AddYouthScreen (tahrirlash)
│   └── main/history → HistoryPage (faoliyat tarixi)
│       └── main/history/add_activity → AddActivityPage
│           ├── Sarlavha, tavsif
│           ├── Geolokatsiya (auto GPS)
│           ├── Selfie tekshirish (yuz tanish, 70%)
│           └── Rasm yuklash (3-10 ta)
│
└── /nazorat_dashboard (DashboardPage - Rahbariyat, 4 tab)
    ├── Tab 1: NazoratMainScreen (statistika, diagrammalar)
    │   ├── Jami/O'g'il/Qiz statistika kartochkalari
    │   ├── 8 ta toifa gridi (API dan)
    │   └── Hududlar bar chart (fl_chart)
    │
    ├── Tab 2: NazoratYoshlarScreen (yoshlar ro'yxati)
    │   ├── Mas'ul bo'yicha filter dropdown
    │   ├── Jins bo'yicha filter dropdown
    │   ├── Qidiruv (search)
    │   ├── Infinite scroll pagination (20 ta)
    │   ├── add_youth → AddYouthScreen (+ rasm yuklash)
    │   ├── edit_youth → AddYouthScreen (tahrirlash + rasm)
    │   ├── nazorat_history → NazoratYoshlarHistory
    │   └── history_into_page → NazoratHistoryIntoPage
    │       ├── Faoliyat tafsilotlari
    │       ├── Rasm galereyasi
    │       ├── Google Maps joylashuv
    │       └── Izohlar (ko'rish/qo'shish)
    │
    ├── Tab 3: NazoratMasulScreen (mas'ullar ro'yxati)
    │   ├── Qidiruv
    │   ├── add_masul → AddOfficerScreen (+ rasm)
    │   ├── edit_masul → AddOfficerScreen (tahrirlash)
    │   ├── masul_yoshlar → MasulYoshlarScreen (yoshlari)
    │   ├── attacht_yoshlar → AttachYouthScreen (biriktirish)
    │   └── Login yaratish / Parol tiklash
    │
    └── Tab 4: ProcessBody (Jarayonlar)
        ├── Mas'ul bo'yicha filter dropdown
        ├── Infinite scroll pagination (20 ta)
        ├── Faoliyat kartochkalari (youthName, title, status, date+time)
        └── Kartochkani bosish → history_into_page
```

---

## 8. Backend Tafsilotlari

### 8.1 Controllerlar (8 ta)

| Controller | Metodlar | Asosiy Funksionallik |
|---|---|---|
| **AuthController** | login, logout, me, updateProfile | Username/password auth, Sanctum token, officer relationship yuklash |
| **YouthController** | index, store, show, update, updatePhoto, destroy | Filter (region/gender/category/officer/search), pagination(20), rasm boshqaruvi, camelCase→snake_case mapping |
| **ActivityController** | index, indexForYouth, store, show, uploadImages | Pagination(20), officer_id auto-set, rasm yuklash (3-10, max 5MB), eager loading |
| **OfficerController** | index, store, update, destroy, show, youths, attachYouths, detachYouths, generateCredentials, resetPassword | CRUD, DB::transaction, rasm boshqaruvi, login yaratish |
| **CommentController** | index, store | Izohlar CRUD (user relationship) |
| **DashboardController** | stats, regions, categories | Statistika, withCount |
| **CategoryController** | index | Toifalar + yoshlar soni |
| **RegionController** | index | Hududlar + yoshlar soni |
| **FaceCompareController** | compare | localhost:5001 ga so'rov yuborish |

### 8.2 Middleware (2 ta)

| Middleware | Alias | Vazifasi |
|---|---|---|
| **EnsureRahbariyat** | `rahbariyat` | User role = rahbariyat tekshirish, 403 qaytarish |
| **EnsureMasul** | `masul` | User role = masul tekshirish, 403 qaytarish |

### 8.3 Form Requests (8 ta)

| Request | Validatsiya | Avtorizatsiya |
|---|---|---|
| **LoginRequest** | login (required), password (required) | Ochiq |
| **StoreYouthRequest** | full_name, birth_date, gender (Erkak/Ayol), region, tags/category_ids | Rahbariyat |
| **UpdateYouthRequest** | Hammasi optional, same rules | Rahbariyat |
| **StoreOfficerRequest** | full_name, position, region, phone | Rahbariyat |
| **UpdateOfficerRequest** | Hammasi optional | Rahbariyat |
| **StoreActivityRequest** | title, date, status (enum), coordinates | Masul |
| **AttachYouthsRequest** | youth_ids (array, min:1) | Rahbariyat |
| **StoreCommentRequest** | body (required) | Auth:sanctum |
| **UpdateProfileRequest** | username (regex, unique), password (min:6, confirmed) | Auth:sanctum |

### 8.4 Resources (8 ta)

| Resource | Xususiyatlar |
|---|---|
| **UserResource** | officer_id, officer_photo flag, officer_photo_url |
| **YouthResource** | camelCase mapping, region/categories/officers relationships, activitiesCount |
| **OfficerResource** | fullName, userId, region name, youthsCount |
| **ActivityResource** | youthName, officer, images, commentsCount, location |
| **CommentResource** | user relationship |
| **CategoryResource** | youthsCount |
| **RegionResource** | youthsCount |
| **ActivityImageResource** | Full storage URL |

### 8.5 Exception Handler (bootstrap/app.php)

| Exception | Status | Xabar (O'zbekcha) |
|---|---|---|
| AuthenticationException | 401 | Avtorizatsiyadan o'tilmagan |
| AuthorizationException | 403 | Ruxsat berilmagan |
| ValidationException | 422 | Ma'lumotlar noto'g'ri + errors |
| ModelNotFoundException | 404 | Ma'lumot topilmadi |
| NotFoundHttpException | 404 | Sahifa topilmadi |
| Throwable | 500 | debug ? message : Ichki server xatosi |

### 8.6 Xizmatlar

| Xizmat | Vazifasi |
|---|---|
| **CredentialGenerator** | O'zbek ismlaridan username yaratish (transliteratsiya), parol generatsiya, uniqueness tekshirish |

### 8.7 Seederlar (7 ta)

| Seeder | Ma'lumotlar |
|---|---|
| RegionSeeder | 13 ta Jizzax tumanlari |
| CategorySeeder | 8 ta yosh toifalari |
| UserSeeder | 4 ta demo foydalanuvchi |
| OfficerSeeder | 5 ta mas'ul xodim |
| YouthSeeder | 20 ta yosh (random toifa va mas'ul) |
| ActivitySeeder | Har yoshga 1-3 ta faoliyat |
| DatabaseSeeder | Barcha seederlarni tartib bilan chaqirish |

---

## 9. Ilg'or Xususiyatlar

### 9.1 Yuz Tanish (Face Recognition)
- Mas'ul faoliyat qo'shishda selfie olish
- Backend `FaceCompareController` → Python servisi (localhost:5001)
- Officer saqlangan rasmi bilan solishtirish
- 70% dan past bo'lsa — faoliyat rad etiladi
- `WebCameraCaptureDialog` — web kamera orqali selfie

### 9.2 Geolokatsiya
- Faoliyat yaratishda avto GPS olish
- `geolocator` paketi (medium accuracy, 5s timeout)
- Latitude/longitude activity bilan saqlanadi
- Rahbariyat Google Maps da ochishi mumkin

### 9.3 Rasm Boshqaruvi
- Yosh rasmi: yaratish/tahrirlashda `image_picker` orqali
- Mas'ul rasmi: officer yaratish/tahrirlashda
- Faoliyat rasmlari: 3-10 ta rasm (max 5MB har biri)
- Multipart upload: `multipartPostWithBytes`, `multipartPostWithBytesList`
- Backend `public` disk, `storage/` katalogida saqlash

### 9.4 Pagination va Infinite Scroll
- Backend: `paginate(20)` — 20 ta har sahifada
- Frontend: `ScrollController` + `loadMore()` (200px threshold)
- `isLoadingMore` flag — takroriy so'rovlar oldini olish
- YouthListCubit, ActivityListCubit — ikkisida ham

### 9.5 Vaqt Zonasi
- Backend UTC da saqlaydi (`created_at` Z suffix)
- Frontend `DateTime.parse().toLocal()` bilan lokal vaqtga o'giradi
- `dateWithTime` getter: "2026-02-10  16:24" formatida ko'rsatadi

### 9.6 Credential Generator
- Mas'ul uchun username avtomatik yaratish (ism → latin transliteratsiya)
- O'zbek harflari: o' → o, g' → g, sh → sh, ch → ch
- Takroriy username bo'lsa raqam qo'shadi
- 8 belgili random parol

---

## 10. Demo Foydalanuvchilar

| Foydalanuvchi | Username | Parol | Rol |
|---|---|---|---|
| Admin Rahbar | admin | password | rahbariyat |
| Abdullayev Jasur | jasur.abdullayev | password | masul |
| Karimov Bobur | bobur.karimov | password | masul |
| Toshmatov Sardor | sardor.toshmatov | password | masul |

---

## 11. Aniqlangan Muammolar va Kamchiliklar

### 11.1 Kritik Muammolar

| # | Muammo | Joylashuvi | Tafsilot |
|---|---|---|---|
| 1 | **Hardcoded Base URL** | `api_client.dart:11-12` | `http://localhost:8000/api` - fizik qurilmada ishlamaydi |
| 2 | **Face Compare servisi hardcoded** | `FaceCompareController.php:34` | `http://127.0.0.1:5001` - env ga ko'chirish kerak |
| 3 | **Rate limiting yo'q** | `api.php` login route | Brute force hujumiga ochiq |
| 4 | **Faoliyat yaratishda avtorizatsiya yo'q** | `ActivityController:store` | Istalgan masul istalgan yoshga faoliyat qo'sha oladi |

### 11.2 Yuqori Darajali Muammolar

| # | Muammo | Joylashuvi | Tafsilot |
|---|---|---|---|
| 1 | **Offline rejim yo'q** | Frontend | Lokal kesh yoki Hive/Isar mavjud emas |
| 2 | **Token yangilash mexanizmi yo'q** | Auth tizimi | Token 24 soatda muddati tugaydi, faqat qayta login |
| 3 | **Soft delete yo'q** | Backend modellari | O'chirilgan ma'lumotlar qaytarib bo'lmaydi |
| 4 | **Audit log yo'q** | Backend | Kim nima qilgani qayd etilmaydi |
| 5 | **Activity tahrirlash/o'chirish yo'q** | Backend API | Yaratilgandan keyin o'zgartirib/o'chirib bo'lmaydi |
| 6 | **Region LIKE query** | `OfficerController`, `YouthController` | `'like', '%region%'` noaniq natija berishi mumkin |

### 11.3 O'rta Darajali Muammolar

| # | Muammo | Joylashuvi | Tafsilot |
|---|---|---|---|
| 1 | **Rasm kompressiyasi yo'q** | Frontend | To'liq o'lchamli rasmlar yuklanadi |
| 2 | **Sana bo'yicha filtrlash yo'q** | Faoliyatlar API | from_date/to_date parametrlari yo'q |
| 3 | **Eksport funksiyasi yo'q** | Backend | CSV/Excel eksport mavjud emas |
| 4 | **Upload timeout yo'q** | `ApiClient` | Katta fayllar uchun timeout belgilanmagan |
| 5 | **Noto'g'ri papka nomi** | `main_item_screen.dart/` | `.dart` kengaytmali papka nomi - chalkash |
| 6 | **Takroriy ActivityCard** | `yoshlar/` va `nazorat/` | Ikki xil `history_item_widget.dart` deyarli bir xil |
| 7 | **Tug'ilgan sana validatsiyasi yo'q** | `StoreYouthRequest.php` | Istalgan sana qabul qilinadi |
| 8 | **N+1 query xavfi** | Controller querylar | `whereHas` bilan filter qilganda potentsial |
| 9 | **Equatable ishlatilmagan** | Dart modellar | Modellar `equatable` ni ishlatmaydi |
| 10 | **Password explicit hash yo'q** | `AuthController`, `OfficerController` | Model cast ga tayangan, `Hash::make()` yaxshiroq |

### 11.4 Past Darajali / Yaxshilash Tavsiyalari

| # | Muammo | Tafsilot |
|---|---|---|
| 1 | Lokalizatsiya (i18n) yo'q | Barcha matnlar Dart/PHP ichida hardcoded |
| 2 | Unit/Widget testlar yo'q | Hech qanday test mavjud emas |
| 3 | API hujjatlari yo'q | Swagger/OpenAPI mavjud emas |
| 4 | Ishlatilmagan kutubxonalar | `shimmer`, `google_nav_bar` |
| 5 | Connectivity tekshiruvi yo'q | Offline holatda xatolik foydalanuvchiga ko'rsatilmaydi |
| 6 | Dark mode yo'q | Faqat light theme |
| 7 | Push notification yo'q | FCM/OneSignal mavjud emas |
| 8 | Error tracking yo'q | Sentry/Crashlytics mavjud emas |
| 9 | Logging yetarli emas | Backend debug mode, frontend stdout |
| 10 | API versioning yo'q | `/api/v1/` emas, faqat `/api/` |

---

## 12. Xavfsizlik Tahlili

| # | Muammo | Jiddiyligi | Tafsilot |
|---|---|---|---|
| 1 | Rate limiting yo'q | **Yuqori** | Login endpoint brute force ga ochiq |
| 2 | Faoliyat yaratish avtorizatsiyasi | **Yuqori** | Masul o'ziga biriktirilmagan yoshga ham faoliyat qo'sha oladi |
| 3 | CORS keng ochiq | **O'rta** | `allowed_headers: *` - productionda cheklash kerak |
| 4 | Face compare HTTP | **O'rta** | HTTPS emas, faqat localhost |
| 5 | Region LIKE injection | **Past** | Eloquent sanitize qiladi, lekin noto'g'ri natija berishi mumkin |
| 6 | Rasm MIME validatsiyasi cheklangan | **Past** | Faqat `image` type, aniq format tekshirilmaydi |

**Kuchli tomonlari:**
- Sanctum token autentifikatsiya
- Middleware orqali rol tekshiruvi
- Password `hashed` cast (auto hash)
- Foreign key constraints (cascade)
- Form Requests validatsiya
- Exception handler (barcha xatoliklar JSON formatda)

---

## 13. Statistika

### Frontend

| Ko'rsatkich | Qiymat |
|---|---|
| Jami Dart fayllari | 54 ta |
| Umumiy hajmi | 476KB |
| Model fayllar | 8 ta |
| Service fayllar | 8 ta |
| Cubit/State fayllar | 12 ta (6 cubit + 6 state) |
| Presentation fayllar | 23 ta |
| Ekranlar soni | 17 ta |
| Papkalar | 18 ta |

### Backend

| Ko'rsatkich | Qiymat |
|---|---|
| Controller fayllar | 8 ta + FaceCompareController |
| Model fayllar | 8 ta |
| Migration fayllar | 13 ta |
| Form Request fayllar | 8 ta |
| Resource fayllar | 8 ta |
| Seeder fayllar | 7 ta |
| Middleware fayllar | 2 ta |
| Service fayllar | 1 ta (CredentialGenerator) |
| API endpointlar | 30+ |

### Demo Ma'lumotlar

| Ko'rsatkich | Qiymat |
|---|---|
| Foydalanuvchilar | 4 ta |
| Mas'ullar | 5 ta |
| Yoshlar | 20 ta |
| Hududlar | 13 ta (Jizzax tumanlari) |
| Toifalar | 8 ta |
| Faoliyatlar | 20-60 ta (random) |

---

## 14. Avvalgi Tahlillar Bilan Taqqoslash

| Jihat | v1 (2026-02-09) | v2 (2026-02-10 tong) | v3 (2026-02-10 kech) |
|---|---|---|---|
| **Holat** | UI prototip | Ishlaydigan MVP | To'liq MVP |
| **Backend** | Yo'q | Laravel REST API | +Activity index, +Photo upload, +Officer filter |
| **DB** | Yo'q | SQLite | MySQL (yoshlar_nazorat) |
| **Auth** | Dekorativ | Sanctum token | +Username login, +Profile update |
| **State management** | Yo'q | 5 Cubit | 6 Cubit (+ActivityListCubit) |
| **Dart fayllari** | 23 | ~50 | 54 |
| **API endpointlar** | 0 | 25+ | 30+ |
| **Jarayonlar** | Hardcoded | Hardcoded | Real API (pagination, filter) |
| **Yoshlar filter** | Ishlamaydi | Region, gender | +Officer filter |
| **Rasm yuklash** | Yo'q | Faoliyat uchun | +Yosh rasmi, +Mas'ul rasmi o'zgartirish |
| **Xarita** | Yo'q | Yandex + Google | Faqat Google Maps |
| **Vaqt ko'rsatish** | Yo'q | Faqat sana | Sana + soat (UTC→local) |
| **Profil** | Yo'q | Yo'q | Username/parol o'zgartirish |
| **Credential gen** | Yo'q | Manual | Avtomatik (transliteratsiya) |

---

## 15. Kod Sifati Bahosi

| Jihat | Baho | Izoh |
|---|---|---|
| Arxitektura | 8/10 | Clean Architecture + BLoC to'g'ri tatbiq etilgan |
| Error Handling | 8/10 | Backend exception handler mukammal, frontend SnackBar |
| DB Dizayni | 8/10 | To'g'ri normalizatsiya, FK constraints |
| Validatsiya | 7/10 | Form Requests yaxshi, lekin ba'zi bo'shliqlar |
| Xavfsizlik | 6/10 | Asosiy himoya bor, rate limiting va audit yo'q |
| Performance | 6/10 | N+1 xavfi, kesh yo'q |
| Testlar | 1/10 | Test yo'q |
| Hujjatlar | 5/10 | Kod o'qiladi, lekin API docs yo'q |
| **Umumiy** | **7/10** | Mustahkam asos, xavfsizlik va test kerak |

---

## 16. Xulosa

### Loyihaning Hozirgi Holati: **To'liq Ishlaydigan MVP**

**Tayyor va ishlaydigan funksionallik:**
1. To'liq autentifikatsiya tizimi (username/password login, token, profil)
2. Ikki rolli tizim middleware himoyasi bilan
3. Yoshlar CRUD (qo'shish, tahrirlash, o'chirish, rasm yuklash)
4. Mas'ullar boshqaruvi (CRUD, credential generation, yoshlar biriktirish)
5. Faoliyat yaratish (rasm, geolokatsiya, yuz tanish)
6. Faoliyat tarixi (rahbariyat va masul uchun, sana+soat)
7. Jarayonlar sahifasi (real API, pagination, officer filter)
8. Dashboard statistika (haqiqiy ma'lumotlar, diagrammalar)
9. Qidiruv va filtrlash (officer, gender, search)
10. Pagination (infinite scroll, 20 ta)
11. Izohlar tizimi
12. Google Maps integratsiya
13. Mas'uldan yoshga rasm yuklash

**Production uchun kerak:**

1. **Xavfsizlik (birinchi navbatda):**
   - Rate limiting (login, API)
   - Faoliyat yaratish avtorizatsiyasi
   - CORS ni cheklash
   - HTTPS

2. **Infratuzilma:**
   - Base URL ni env variable ga ko'chirish
   - Face compare URL ni env ga ko'chirish
   - Proper server deployment

3. **Funksional:**
   - Offline rejim
   - Token refresh
   - Faoliyat tahrirlash/o'chirish
   - Rasm kompressiyasi
   - Eksport (CSV/Excel)

4. **Sifat:**
   - Unit/Widget/Integration testlar
   - API hujjatlari (Swagger)
   - Audit logging
   - Error tracking

---

*Tahlil sanasi: 2026-02-10 (yangilangan)*
*Tahlil qiluvchi: Claude Code*
*Versiya: v3 (to'liq backend + frontend tahlil)*
