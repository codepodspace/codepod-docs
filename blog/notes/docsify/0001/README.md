
参考地址：

https://docsify.js.org/#/write-a-plugin?id=edit-button-github

https://docsify.js.org/#/configuration?id=formatupdated

```html
<script>
  window.$docsify = {
    plugins: [
      function editButton(hook, vm) {
        $docsify.formatUpdated = "{YYYY}/{MM}/{DD} {HH}:{mm}";

        hook.beforeEach(function (html) {
          var url =
            "https://github.com/codepodspace/codepod-docs/blob/master/" +
            vm.route.file;
          var editHtml = "[📝 EDIT DOCUMENT](" + url + ")\n";

          return (
            html + "\n----\n" + "Last modified {docsify-updated}" + editHtml
          );
        });
      },
    ],
  };
</script>
```
