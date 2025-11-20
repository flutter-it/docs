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
              { text: 'Command Builders', link: '/documentation/command_it/command_builders.md' },
              { text: 'Error Handling', link: '/documentation/command_it/error_handling.md' },
              { text: 'Error Filters', link: '/documentation/command_it/error_filters.md' },
              { text: 'Restrictions', link: '/documentation/command_it/restrictions.md' },
              { text: 'Testing', link: '/documentation/command_it/testing.md' },
              { text: 'watch_it Integration', link: '/documentation/command_it/watch_it_integration.md' },
              { text: 'Best Practices', link: '/documentation/command_it/best_practices.md' }
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
