Examples
Syntax
1. If `condition` is `true` the result is `true_value`, if `condition` is `false` then the result is `false_value`
`condition ? true_value : false_value`

2. Common use of conditional expressions is to define defaults to replace invalid values:
`var.a != "" ? var.a : default-a`
If `var.a` is an empty string the result is `default.a` but otherwise it is the acual value of `var.a`

3. `var.host_os == "windows" ? "powershell" : "bash"` and `var.host_os == "linux" ? "powershell" : "bash"`

4. `var.host_os == "windows" ? ["Powershell", "-Command"] : ["bash", "-c"]`