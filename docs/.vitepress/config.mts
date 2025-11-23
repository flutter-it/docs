import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "flutter_it",
  description: "Build reactive Flutter apps the easy way - no codegen, no boilerplate, just code",

  // Favicon
  head: [
    ['link', { rel: 'icon', type: 'image/png', href: '/favicon.png' }]
  ],

  // Ensure proper file handling
  cleanUrls: true,

  // Ignore dead links for documentation that's still being developed
  ignoreDeadLinks: [
    /\/documentation\/(watch_it|command_it)\/getting_started/
  ],

  // Multi-language support
  locales: {
    root: {
      label: 'English',
      lang: 'en'
    },
    es: {
      label: 'Español',
      lang: 'es',
      title: "flutter_it",
      description: "Crea apps Flutter reactivas de forma sencilla - sin generación de código, sin código repetitivo, solo código",
      themeConfig: {
        nav: [
          { text: 'Inicio', link: '/es/' },
          { text: 'Primeros Pasos', link: '/es/getting_started/what_to_do_with_which_package' },
          { text: 'Documentación', link: '/es/documentation/overview' },
          { text: 'Ejemplos', link: '/es/examples/overview' },
          { text: 'Artículos', link: '/es/misc/articles' }
        ],
        sidebar: [
          {
            text: 'Primeros Pasos',
            collapsed: false,
            items: [
              { text: 'Qué hacer con cada paquete', link: '/es/getting_started/what_to_do_with_which_package' },
              { text: 'get_it', link: '/es/documentation/get_it/getting_started' },
              { text: 'watch_it', link: '/es/documentation/watch_it/getting_started' },
              { text: 'command_it', link: '/es/documentation/command_it/getting_started' },
              { text: 'listen_it', link: '/es/documentation/listen_it/listen_it' }
            ]
          },
          {
            text: 'Documentación',
            collapsed: false,
            items: [
              { text: 'Descripción general', link: '/es/documentation/overview' },
              {
                text: 'get_it',
                collapsed: true,
                items: [
                  { text: 'Primeros pasos', link: '/es/documentation/get_it/getting_started' },
                  { text: 'Registro de objetos', link: '/es/documentation/get_it/object_registration' },
                  { text: 'Scopes', link: '/es/documentation/get_it/scopes' },
                  { text: 'Objetos asíncronos', link: '/es/documentation/get_it/async_objects' },
                  { text: 'Registros múltiples', link: '/es/documentation/get_it/multiple_registrations' },
                  { text: 'Avanzado', link: '/es/documentation/get_it/advanced' },
                  { text: 'Pruebas', link: '/es/documentation/get_it/testing' },
                  { text: 'Extensión DevTools', link: '/es/documentation/get_it/devtools_extension' },
                  { text: 'Flutter Previews', link: '/es/documentation/get_it/flutter_previews' },
                  { text: 'Preguntas frecuentes', link: '/es/documentation/get_it/faq' }
                ]
              },
              {
                text: 'watch_it',
                collapsed: true,
                items: [
                  { text: 'Getting started', link: '/es/documentation/watch_it/getting_started' },
                  { text: 'Your First Watch Functions', link: '/es/documentation/watch_it/your_first_watch_functions' },
                  { text: 'More Watch Functions', link: '/es/documentation/watch_it/more_watch_functions' },
                  { text: 'Watching Multiple Values', link: '/es/documentation/watch_it/watching_multiple_values' },
                  { text: 'Watching Streams & Futures', link: '/es/documentation/watch_it/watching_streams_and_futures' },
                  { text: 'Watch Ordering Rules', link: '/es/documentation/watch_it/watch_ordering_rules' },
                  { text: 'Side Effects with Handlers', link: '/es/documentation/watch_it/handlers' },
                  { text: 'Lifecycle Functions', link: '/es/documentation/watch_it/lifecycle' },
                  { text: 'WatchingWidgets', link: '/es/documentation/watch_it/watching_widgets' },
                  { text: 'Observing Commands', link: '/es/documentation/watch_it/observing_commands' },
                  { text: 'Accessing get_it Features', link: '/es/documentation/watch_it/advanced_integration' },
                  { text: 'Best Practices', link: '/es/documentation/watch_it/best_practices' },
                  { text: 'Debugging & Troubleshooting', link: '/es/documentation/watch_it/debugging_tracing' },
                  { text: 'How watch_it Works', link: '/es/documentation/watch_it/how_it_works' }
                ]
              },
              {
                text: 'command_it',
                collapsed: true,
                items: [
                  { text: 'Getting started', link: '/documentation/command_it/getting_started' },
                  { text: 'Command Basics', link: '/documentation/command_it/command_basics' },
                  { text: 'Command Types', link: '/documentation/command_it/command_types' },
                  { text: 'Command Properties', link: '/documentation/command_it/command_properties' },
                  { text: 'Command Results', link: '/documentation/command_it/command_results' },
                  { text: 'Global Configuration', link: '/documentation/command_it/global_configuration' },
                  { text: 'Command Builders', link: '/documentation/command_it/command_builders' },
                  { text: 'Error Handling', link: '/documentation/command_it/error_handling' },
                  { text: 'Restrictions', link: '/documentation/command_it/restrictions' },
                  { text: 'Optimistic Updates', link: '/documentation/command_it/optimistic_updates' },
                  { text: 'Testing', link: '/documentation/command_it/testing' },
                  { text: 'Without watch_it', link: '/documentation/command_it/without_watch_it' },
                  { text: 'Best Practices', link: '/documentation/command_it/best_practices' },
                  { text: 'Troubleshooting', link: '/documentation/command_it/troubleshooting' }
                ]
              },
              {
                text: 'listen_it',
                collapsed: true,
                items: [
                  { text: 'Listen', link: '/es/documentation/listen_it/listen_it' },
                  {
                    text: 'Operators',
                    collapsed: true,
                    items: [
                      { text: 'Descripción general', link: '/es/documentation/listen_it/operators/overview' },
                      { text: 'Transform (map, select)', link: '/es/documentation/listen_it/operators/transform' },
                      { text: 'Filter (where)', link: '/es/documentation/listen_it/operators/filter' },
                      { text: 'Combine (combineLatest, mergeWith)', link: '/es/documentation/listen_it/operators/combine' },
                      { text: 'Time (debounce)', link: '/es/documentation/listen_it/operators/time' }
                    ]
                  },
                  {
                    text: 'Colecciones',
                    collapsed: true,
                    items: [
                      { text: 'Introducción', link: '/es/documentation/listen_it/collections/introduction' },
                      { text: 'ListNotifier', link: '/es/documentation/listen_it/collections/list_notifier' },
                      { text: 'MapNotifier', link: '/es/documentation/listen_it/collections/map_notifier' },
                      { text: 'SetNotifier', link: '/es/documentation/listen_it/collections/set_notifier' },
                      { text: 'Modos de Notificación', link: '/es/documentation/listen_it/collections/notification_modes' },
                      { text: 'Transacciones', link: '/es/documentation/listen_it/collections/transactions' }
                    ]
                  },
                  { text: 'Mejores Prácticas', link: '/es/documentation/listen_it/best_practices' }
                ]
              }
            ]
          },
          {
            text: 'Ejemplos',
            collapsed: true,
            items: [
              { text: 'Descripción general', link: '/es/examples/overview' },
              { text: 'get_it', link: '/examples/get_it/get_it' },
              { text: 'watch_it', link: '/examples/watch_it/watch_it' },
              { text: 'command_it', link: '/examples/command_it/command_it' },
              { text: 'listen_it', link: '/examples/listen_it/listen_it' },
              { text: 'advanced', link: '/examples/advanced/advanced' }
            ]
          },
          {
            text: 'Misc.',
            collapsed: false,
            items: [
              { text: 'Artículos y Videos', link: '/es/misc/articles' },
              { text: 'How to contribute', link: '/misc/contribute' }
            ]
          }
        ],
        socialLinks: [
          { icon: 'github', link: 'https://github.com/flutter-it' },
          { icon: 'discord', link: 'https://discord.com/invite/Nn6GkYjzW' },
          { icon: 'twitter', link: 'https://x.com/ThomasBurkhartB' }
        ],
        footer: {
          message: 'Publicado bajo la Licencia MIT.',
          copyright: 'Copyright © 2024-presente flutter_it'
        },
        outline: {
          level: [2, 3],
          label: 'En esta página'
        }
      }
    }
  },

  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Getting Started', link: '/getting_started/what_to_do_with_which_package.md' },
      { text: 'Documentation', link: '/documentation/overview.md' },
      { text: 'Examples', link: '/examples/overview.md' },
      { text: 'Articles', link: '/misc/articles.md' }
    ],

    // Single unified sidebar configuration for all pages
    sidebar: [
      {
        text: 'Getting Started',
        collapsed: false,
        items: [
          { text: 'What to do with which package', link: '/getting_started/what_to_do_with_which_package.md' },
          { text: 'get_it', link: '/documentation/get_it/getting_started.md' },
          { text: 'watch_it', link: '/documentation/watch_it/getting_started.md' },
          { text: 'command_it', link: '/documentation/command_it/getting_started.md' },
          { text: 'listen_it', link: '/documentation/listen_it/listen_it.md' }
        ]
      },
      {
        text: 'Documentation',
        collapsed: false,
        items: [
          { text: 'Overview', link: '/documentation/overview.md' },
          {
            text: 'get_it',
            collapsed: true,
            items: [
              { text: 'Getting started', link: '/documentation/get_it/getting_started.md' },
              { text: 'Object registration', link: '/documentation/get_it/object_registration.md' },
              { text: 'Scopes', link: '/documentation/get_it/scopes.md' },
              { text: 'Async objects', link: '/documentation/get_it/async_objects.md' },
              { text: 'Multiple registrations', link: '/documentation/get_it/multiple_registrations.md' },
              { text: 'Advanced', link: '/documentation/get_it/advanced.md' },
              { text: 'Testing', link: '/documentation/get_it/testing.md' },
              { text: 'DevTools Extension', link: '/documentation/get_it/devtools_extension.md' },
              { text: 'Flutter Previews', link: '/documentation/get_it/flutter_previews.md' },
              { text: 'FAQ', link: '/documentation/get_it/faq.md' }
            ]
          },
          {
            text: 'watch_it',
            collapsed: true,
            items: [
              { text: 'Getting started', link: '/documentation/watch_it/getting_started.md' },
              { text: 'Your First Watch Functions', link: '/documentation/watch_it/your_first_watch_functions.md' },
              { text: 'More Watch Functions', link: '/documentation/watch_it/more_watch_functions.md' },
              { text: 'Watching Multiple Values', link: '/documentation/watch_it/watching_multiple_values.md' },
              { text: 'Watching Streams & Futures', link: '/documentation/watch_it/watching_streams_and_futures.md' },
              { text: 'Watch Ordering Rules', link: '/documentation/watch_it/watch_ordering_rules.md' },
              { text: 'Side Effects with Handlers', link: '/documentation/watch_it/handlers.md' },
              { text: 'Lifecycle Functions', link: '/documentation/watch_it/lifecycle.md' },
              { text: 'WatchingWidgets', link: '/documentation/watch_it/watching_widgets.md' },
              { text: 'Observing Commands', link: '/documentation/watch_it/observing_commands.md' },
              { text: 'Accessing get_it Features', link: '/documentation/watch_it/advanced_integration.md' },
              { text: 'Best Practices', link: '/documentation/watch_it/best_practices.md' },
              { text: 'Debugging & Troubleshooting', link: '/documentation/watch_it/debugging_tracing.md' },
              { text: 'How watch_it Works', link: '/documentation/watch_it/how_it_works.md' }
            ]
          },
          {
            text: 'command_it',
            collapsed: true,
            items: [
              { text: 'Getting started', link: '/documentation/command_it/getting_started.md' },
              { text: 'Command Basics', link: '/documentation/command_it/command_basics.md' },
              { text: 'Command Types', link: '/documentation/command_it/command_types.md' },
              { text: 'Command Properties', link: '/documentation/command_it/command_properties.md' },
              { text: 'Command Results', link: '/documentation/command_it/command_results.md' },
              { text: 'Global Configuration', link: '/documentation/command_it/global_configuration.md' },
              { text: 'Command Builders', link: '/documentation/command_it/command_builders.md' },
              { text: 'Error Handling', link: '/documentation/command_it/error_handling.md' },
              { text: 'Restrictions', link: '/documentation/command_it/restrictions.md' },
              { text: 'Optimistic Updates', link: '/documentation/command_it/optimistic_updates.md' },
              { text: 'Testing', link: '/documentation/command_it/testing.md' },
              { text: 'Without watch_it', link: '/documentation/command_it/without_watch_it.md' },
              { text: 'Best Practices', link: '/documentation/command_it/best_practices.md' },
              { text: 'Troubleshooting', link: '/documentation/command_it/troubleshooting.md' }
            ]
          },
          {
            text: 'listen_it',
            collapsed: true,
            items: [
              { text: 'Listen', link: '/documentation/listen_it/listen_it.md' },
              {
                text: 'Operators',
                collapsed: true,
                items: [
                  { text: 'Overview', link: '/documentation/listen_it/operators/overview.md' },
                  { text: 'Transform (map, select)', link: '/documentation/listen_it/operators/transform.md' },
                  { text: 'Filter (where)', link: '/documentation/listen_it/operators/filter.md' },
                  { text: 'Combine (combineLatest, mergeWith)', link: '/documentation/listen_it/operators/combine.md' },
                  { text: 'Time (debounce)', link: '/documentation/listen_it/operators/time.md' }
                ]
              },
              {
                text: 'Collections',
                collapsed: true,
                items: [
                  { text: 'Introduction', link: '/documentation/listen_it/collections/introduction.md' },
                  { text: 'ListNotifier', link: '/documentation/listen_it/collections/list_notifier.md' },
                  { text: 'MapNotifier', link: '/documentation/listen_it/collections/map_notifier.md' },
                  { text: 'SetNotifier', link: '/documentation/listen_it/collections/set_notifier.md' },
                  { text: 'Notification Modes', link: '/documentation/listen_it/collections/notification_modes.md' },
                  { text: 'Transactions', link: '/documentation/listen_it/collections/transactions.md' }
                ]
              },
              { text: 'Best Practices', link: '/documentation/listen_it/best_practices.md' }
            ]
          }
        ]
      },
      {
        text: 'Examples',
        collapsed: true,
        items: [
          { text: 'Overview', link: '/examples/overview.md' },
          { text: 'get_it', link: '/examples/get_it/get_it.md' },
          { text: 'watch_it', link: '/examples/watch_it/watch_it.md' },
          { text: 'command_it', link: '/examples/command_it/command_it.md' },
          { text: 'listen_it', link: '/examples/listen_it/listen_it.md' },
          { text: 'advanced', link: '/examples/advanced/advanced.md' }
        ]
      },
      {
        text: 'Misc.',
        collapsed: false,
        items: [
          { text: 'Articles & Videos', link: '/misc/articles.md' },
          { text: 'How to contribute', link: '/misc/contribute.md' }
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/flutter-it' },
      { icon: 'discord', link: 'https://discord.com/invite/Nn6GkYjzW' },
      { icon: 'twitter', link: 'https://x.com/ThomasBurkhartB' }
    ],

    footer: {
      message: 'Released under the MIT License.',
      copyright: 'Copyright © 2024-present flutter_it'
    },

    // Additional theme options
    outline: {
      level: [2, 3],
      label: 'On this page'
    },

    // Ensure sidebar is always visible
    aside: true
  }
})
