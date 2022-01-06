{{ $latest := index .Versions 0 }}
<a name="{{ $latest.Tag.Name }}"></a>
## {{ if $latest.Tag.Previous }}[{{ $latest.Tag.Name }}]({{ $.Info.RepositoryURL }}/compare/{{ $latest.Tag.Previous.Name }}...{{ $latest.Tag.Name }}){{ else }}{{ $latest.Tag.Name }}{{ end }} ({{ datetime "2006-01-02" $latest.Tag.Date }})

{{ range $latest.CommitGroups -}}
### {{ .Title }}

{{ range .Commits -}}
* {{ .Subject }}
{{ end }}
{{ end -}}

{{- if $latest.NoteGroups -}}
{{ range $latest.NoteGroups -}}
### {{ .Title }}

{{- range .Notes }}
{{ .Body }}
{{ end }}
{{ end -}}
{{ end -}}
