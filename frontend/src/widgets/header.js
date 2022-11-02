import { Link } from 'react-router-dom';
import { useAuth0 } from "@auth0/auth0-react";

const LoginButton = () => {
  const { loginWithRedirect } = useAuth0();

  return (
    <a onClick={() => loginWithRedirect()}>Log in</a>
  );
};

const LogoutButton = () => {
  const { logout } = useAuth0();

  return (
    <a onClick={() => logout({ returnTo: window.location.origin})}>Log out</a>
  );
};

const UserActions = () => <>
  <Link to="/profile">Profile</Link> / <LogoutButton />
</>;

const Header = () => {
  const { isAuthenticated } = useAuth0();

  return (
    <div className="app-header">
      <div>
        <Link to="/">TaskJuggler</Link>
      </div>

      <div className="app-header-rhs">
        { isAuthenticated ? <UserActions /> : <LoginButton /> }
      </div>
    </div>
  );
}

export default Header;
