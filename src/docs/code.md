# Code Example

### PHP

```php
class App {

  /**
  * @var string
  */
  private $name;

  public __construct($name)
  {
    $this->name = $name;
  }
}
```

### C#

```csharp
public class App {

  private string Name {get; set;}

  public App(string name)
  {
    this.Name = name;
  }
}
```

### Json 

```json
{"result":"success"}
```

### Bash

```bash
curl -H 'Content-type: application/json' http://localhost:8080/api/
```