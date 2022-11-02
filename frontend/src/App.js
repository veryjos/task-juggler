import { useAuth0 } from "@auth0/auth0-react";
import { BrowserRouter, Route, Routes, Outlet } from 'react-router-dom';
import Home from './routes/home';
import Profile from './routes/profile';
import Header from './widgets/header';
import './App.css';

const ProtectedRoute = () => {
  const { loginWithRedirect, isAuthenticated } = useAuth0();

  if (!isAuthenticated) {
    loginWithRedirect();

    return <>Redirecting to login..</>;
  }

  return <Outlet />;
};

const App = () => {
  const { isLoading } = useAuth0();

  return (
    !isLoading && <BrowserRouter>
      <div className="app-content">
        <Header />

        <div className="app-content-wrap">
          <Routes>
            <Route path="/" element={<Home />} />

            <Route element={<ProtectedRoute />}>
              <Route path="/profile" element={<Profile />} />
            </Route>
          </Routes>
        </div>
      </div>
    </BrowserRouter>
  );
};

export default App;
