lib/
│ main.dart
│ env.dart
│
├── core/ # shared app-wide things
│ ├── config/
│ ├── constants/
│ ├── utils/
│ └── widgets/ # reusable UI (buttons, loaders, etc.)
│
├── shared/ # shared models/providers across features
│ ├── models/
│ │ firm.dart
│ │ profile.dart
│ └── providers/
│
├── features/
│
│ ├── site/
│ │ ├── model/
│ │ │ site.dart
│ │ ├── repository/
│ │ │ site_repository.dart
│ │ ├── provider/
│ │ │ site_provider.dart
│ │ └── ui/
│ │ sites_screen.dart
│ │ widgets/
│ │ site_card.dart
│ │ firm_filter.dart
│ │ status_filter.dart
│
│ ├── expense/
│ │ ├── model/
│ │ ├── repository/
│ │ ├── provider/
│ │ └── ui/
│ │
│ ├── document/
│ │ ├── model/
│ │ ├── repository/
│ │ ├── provider/
│ │ └── ui/
│ │
│ ├── dashboard/
│ │ └── ui/
│
│ └── auth/ # optional later
│
└── app/
├── router.dart
└── app.dart
