import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { Toaster } from 'sonner';
import Login from '@/pages/Login/Login';
import Dashboard from '@/pages/Dashboard/Dashboard';
import ArbolList from '@/pages/Arboles/ArbolList';
import { useAuthStore } from '@/context/AuthContext';

function PrivateRoute({ children }: { children: React.ReactNode }) {
  const isAuthenticated = useAuthStore((state) => state.isAuthenticated);
  return isAuthenticated ? <>{children}</> : <Navigate to="/login" />;
}

function App() {
  return (
    <BrowserRouter>
      <Toaster position="top-right" />
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route
          path="/"
          element={
            <PrivateRoute>
              <Dashboard />
            </PrivateRoute>
          }
        />
        <Route
          path="/arboles"
          element={
            <PrivateRoute>
              <ArbolList />
            </PrivateRoute>
          }
        />
        {/* TODO: Add more routes */}
      </Routes>
    </BrowserRouter>
  );
}

export default App;
