import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "flutter_it",
  description: "All you need for organizing your flutter apps",
  
  // Ensure proper file handling
  cleanUrls: true,
  base: '/docs/',
  
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
          { text: 'watch_it', link: '/documentation/watch_it/watch_it.md' },
          { text: 'command_it', link: '/documentation/command_it/command_it.md' },
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
              { text: 'Testing', link: '/documentation/get_it/testing.md' },
              { text: 'Advanced', link: '/documentation/get_it/advanced.md' },
              { text: 'FAQ', link: '/documentation/get_it/faq.md' }
            ]
          },
          { text: 'watch_it', link: '/documentation/watch_it/watch_it.md' },
          { text: 'command_it', link: '/documentation/command_it/command_it.md' },
          { text: 'listen_it', link: '/documentation/listen_it/listen_it.md' }
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
