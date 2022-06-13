{{ $latest := index .Versions 0 -}}
{{ if $latest.CommitGroups -}}
true
{{ else -}}
false
{{ end -}}
