import logo from './logo.svg';
import './App.css';

import { useAuth0 } from "@auth0/auth0-react";

const LoginButton = () => {
  const { loginWithRedirect } = useAuth0();

  return <button onClick={() => loginWithRedirect()}>Log In</button>;
};

const LogoutButton = () => {
  const { logout } = useAuth0();

  return (
    <button onClick={() => logout({ returnTo: window.location.origin })}>
      Log Out
    </button>
  );
};

function App() {
  const { isAuthenticated } = useAuth0();

  return (
    <div className="App">
      <header className="App-header">
        <p>insert taskjuggler v2 home page :)</p>
      </header>

      { isAuthenticated && <span>you are logged in</span> }

      <LoginButton />
      <LogoutButton />
    </div>
  );
}

export default App;
