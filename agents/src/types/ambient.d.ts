// agents/src/types/ambient.d.ts
// Ambient module declarations for custom asset formats

declare module '*.md' {
  const content: string
  export default content
}
