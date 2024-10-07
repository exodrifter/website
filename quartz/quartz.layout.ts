import { PageLayout, SharedLayout } from "./quartz/cfg"
import * as Component from "./quartz/components"

// components shared across all pages
export const sharedPageComponents: SharedLayout = {
  head: Component.CustomHead(),
  header: [],
  afterBody: [],
  footer: Component.Footer({
    links: {
      "GitHub": "https://github.com/exodrifter/website",
      "Discord": "https://discord.gg/arqFQVt",
    },
  }),
}

// components for pages that display a single page (e.g. a single note)
export const defaultContentPageLayout: PageLayout = {
  beforeBody: [
    Component.Breadcrumbs(),
    Component.NotIndex(Component.ContentMeta()),
    Component.NotIndex(Component.TagList()),
  ],
  left: [
    Component.BrandingLogo({ path: "logo.svg" }),
    Component.MobileOnly(Component.Spacer()),
    Component.Search(),
    Component.Darkmode(),
  ],
  right: [
    Component.DesktopOnly(Component.TableOfContents({ layout: "legacy" })),
    Component.Crossposts(),
    Component.CustomBacklinks(),
  ],
}

// components for pages that display lists of pages  (e.g. tags or folders)
export const defaultListPageLayout: PageLayout = {
  beforeBody: [
    Component.Breadcrumbs(),
    Component.NotIndex(Component.ContentMeta()),
  ],
  left: [
    Component.BrandingLogo({ path: "logo.svg" }),
    Component.MobileOnly(Component.Spacer()),
    Component.Search(),
    Component.Darkmode(),
  ],
  right: [
    Component.DesktopOnly(Component.TableOfContents({ layout: "legacy" })),
    Component.Crossposts(),
    Component.CustomBacklinks(),
  ],
}
