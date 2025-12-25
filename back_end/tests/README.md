# Tests Directory

Thư mục này chứa tất cả các file test cho backend.

## Cấu trúc

```
tests/
├── unit/               # Unit tests
│   ├── controllers/    # Test cho controllers
│   ├── services/       # Test cho services
│   ├── utils/          # Test cho utilities
│   └── middleware/     # Test cho middleware
├── integration/        # Integration tests
├── fixtures/           # Test data fixtures
└── helpers/            # Test helper functions
```

## Lưu ý

- Tất cả file test nên đặt trong thư mục này
- Không đặt file test ở root của back_end
- Sử dụng naming convention: `*.test.js` hoặc `*.spec.js`
