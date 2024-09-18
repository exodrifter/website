import { formatDate } from "./Date"
import { QuartzComponent, QuartzComponentConstructor, QuartzComponentProps } from "./types"
import style from "./styles/backlinks.scss"
import { resolveRelative, simplifySlug } from "../util/path"
import { i18n } from "../i18n"
import { classNames } from "../util/lang"

const Crossposts: QuartzComponent = ({
  fileData,
  displayClass,
  cfg,
}: QuartzComponentProps) => {
  const crossposts = fileData.frontmatter["crossposts"]
  if (crossposts == null || crossposts.length == 0) {
    return <></>
  }
  crossposts.sort(function(a, b) {
    return b.time - a.time;
  })
  return (
    <div class={classNames(displayClass, "backlinks")}>
      <h3>Crossposts</h3>
      <ul class="overflow">
        {crossposts.map((f) => (
            <li>
              {formatDate(new Date(f.time)!, cfg.locale)}
              <br/>
              <a href={f.url} class="internal">
                {new URL(f.url).host}
              </a>
            </li>
          ))
        }
      </ul>
    </div>
  )
}

Crossposts.css = style
export default (() => Crossposts) satisfies QuartzComponentConstructor
