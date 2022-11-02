import logo from './logo.svg';
import { useAuth0 } from "@auth0/auth0-react";
import './App.css';
import {
  BrowserRouter,
  Route,
  Routes,
  Outlet,
  createRoutesFromElements,
} from 'react-router-dom';
import Home from './routes/home';
import Profile from './routes/profile';
import Header from './widgets/header';

const App = () => {
  const { isLoading } = useAuth0();

  return (
    !isLoading && <BrowserRouter>
      <div className="app-content">
        <Header />

        <div className="app-content-wrap">
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/profile" element={<Profile />} />
          </Routes>
        </div>
      </div>
    </BrowserRouter>
  );
};

export default App;
