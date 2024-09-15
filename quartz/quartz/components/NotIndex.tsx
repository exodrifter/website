import { QuartzComponent, QuartzComponentConstructor, QuartzComponentProps } from "./types"

export default ((component?: QuartzComponent) => {
  if (component) {
    const Component = component
    const NotIndex: QuartzComponent = (props: QuartzComponentProps) => {
      if (props.fileData.slug === "index") {
        return <></>
      }
      return <Component {...props} />
    }

    NotIndex.displayName = component.displayName
    NotIndex.afterDOMLoaded = component?.afterDOMLoaded
    NotIndex.beforeDOMLoaded = component?.beforeDOMLoaded
    NotIndex.css = component?.css
    return NotIndex
  } else {
    return () => <></>
  }
}) satisfies QuartzComponentConstructor
