import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "flutter_it",
  description: "Build reactive Flutter apps the easy way - no codegen, no boilerplate, just code",

  // Ensure proper file handling
  cleanUrls: true,

  // Ignore dead links for documentation that's still being developed
  ignoreDeadLinks: [
    /\/documentation\/(watch_it|command_it)\/getting_started/
  ],

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
        collapsed: true,
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
              { text: 'FAQ', link: '/documentation/get_it/faq.md' }
            ]
          },
          {
            text: 'watch_it',
            collapsed: true,
            items: [
              { text: 'Getting started', link: '/documentation/watch_it/getting_started.md' },
              { text: 'Watch functions', link: '/documentation/watch_it/watch_functions.md' },
              { text: 'callOnce & createOnce', link: '/documentation/watch_it/call_once_create_once.md' },
              { text: 'Additional goodies', link: '/documentation/watch_it/additional_goodies.md' },
              { text: 'Integration with get_it', link: '/documentation/watch_it/integration.md' },
              { text: 'Debugging and tracing', link: '/documentation/watch_it/debugging_tracing.md' },
              { text: 'Best practices', link: '/documentation/watch_it/best_practices.md' },
              { text: 'How does it work?', link: '/documentation/watch_it/how_it_works.md' }
            ]
          },
          {
            text: 'command_it',
            collapsed: true,
            items: [
              { text: 'Getting started', link: '/documentation/command_it/getting_started.md' },
              { text: 'Command types', link: '/documentation/command_it/command_types.md' },
              { text: 'Command builders', link: '/documentation/command_it/command_builders.md' },
              { text: 'Error handling', link: '/documentation/command_it/error_handling.md' }
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
              }
            ]
          }
        ]
      },
      {
        text: 'Examples',
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
        items: [
          { text: 'Articles & Videos', link: '/misc/articles.md' },
          { text: 'How to contribute', link: '/misc/contribute.md' }
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/flutter-it' },
      { icon: 'discord', link: 'https://discord.gg/g5hUvhRz' },
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
