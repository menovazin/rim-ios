# RIM (iOS+TCA)

## Краткое описание

Нативное iOS-приложение для просмотра персонажей, эпизодов и локаций вселенной Rick and Morty. SwiftUI + The Composable Architecture (TCA), управление проектом через Tuist.

---

## Стек технологий

| Слой | Технология | Назначение |
|---|---|---|
| UI | SwiftUI | Декларативный UI |
| Архитектура | The Composable Architecture (TCA) | `@Reducer` / `@ObservableState` |
| Генерация проекта | Tuist | Модульный Xcode-проект |
| Минимальный iOS | iOS 17 | Modern `NavigationStack`, `@Observable`-эра TCA |
| Сеть | URLSession + async/await | `APIClient`, каталоги character/episode/location |
| Изображения | Kingfisher | Загрузка аватарок |
| Хранение | Keychain (`TokenStore`) | Токен fake-login |

---

## Особенности

- **Модульная структура Tuist:** `App` (вход, app-root reducer) · `DesignSystem` (токены, шрифты, `RimDrawer`) · `Networking` (`APIClient` на URLSession + async/await) · `Models` (доменные сущности + `Codable` DTO) · `Features` (TCA-редьюсеры + SwiftUI-вью на каждый экран).
- **Fake-login** — экран входа с токеном, auth-гейт при старте.
- **Characters: адаптивный grid** — 1–6 колонок по ширине экрана; Episodes и Locations — списки с той же пагинацией.
- **Пагинация (infinite scroll)** — load-more по трём каталогам.
- **Боковое меню** — bespoke `RimDrawer` из DesignSystem: Персонажи, Эпизоды, Локации, Выйти.
- **Тема** — light / dark / system (persist).
- **Навигация** — `NavigationStack`-эра TCA, type-safe.
- **Локализация** — English-only.

---

## Запуск

Требуется Xcode 15+ и iOS 17 SDK.

```bash
cd rim_ios
tuist generate
xed rim_ios.xcworkspace
```

---

## Ссылки

- Хаб: https://github.com/menovazin/rim-main
- Бэкенд: https://github.com/menovazin/rim-backend
