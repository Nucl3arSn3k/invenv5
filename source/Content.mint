component Content {
  // Styles for the root element.
  style root {
    max-width: 72ch;
    font-size: 20px;
    color: #333;
    code {
      padding: 0.15em 0.3em 0.1em;
      border: 1px solid #EEE;
      border-radius: 0.15em;
      background: #F6F6F6;
      font-size: 0.9em;
    }
    a {
      color:rgb(10, 78, 33);
    }
    h3 {
      margin-top: 0;
    }
    li + li {
      margin-top: 0.5em;
    }
    blockquote {
      border-left: 3px solid #EEE;
      font-style: italic;
      padding-left: 15px;
      font-size: 0.8em;
      margin-bottom: 0;
      margin-top: 30px;
      margin-left: 0;
      p {
        margin: 0;
      }
    }
    @media (max-width: 600px) {
      font-size: 16px;
      ul {
        padding-left: 20px;
      }
    }
  }

  state username : String = ""
  state password : String = ""

  // Function to handle username change
  fun handleUsername (event : Html.Event) {
    next { username: Dom.getValue(event.target) }
  }

  // Function to handle password change
  fun handlePassword (event : Html.Event) {
    next { password: Dom.getValue(event.target) }
  }

  fun render : Html {
    <div::root>
      <form>
        <label for="username">"Username"</label>
        <br/>
        <input
          type="text"
          id="username"
          value={username}
          onInput={handleUsername}/>
        <br/>
        <label for="password">"Password"</label>
        <br/>
        <input
          type="password"
          id="password"
          value={password}
          onInput={handlePassword}/>
        <br/>
        <br/>
        <input type="submit" value="Submit"/>
      </form>
    </div>
  }
}