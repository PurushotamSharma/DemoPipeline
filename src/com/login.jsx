import React, { useState } from 'react'
import { useHistory } from 'react-router-dom'

function Login() {
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const history = useHistory()

  const handleSubmit = (e) => {
    e.preventDefault()
    if (username === 'admin' && password === 'password') {
      history.push('/dashboard')
    } else {
      alert('Invalid credentials') //cdsccdcdscsdscscscsfdfggdsgdgdfbdfghghdfghfgdfhdfghfghdfghdfhdffdhdfghdfhdhgdfhgdsfggdfgdf
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <label>
        Username:
        <input type="text" value={username} onChange={e => setUsername(e.target.value)} />
      </label>
      <br />
      <label>
        Password:
        <input type="password" value={password} onChange={e => setPassword(e.target.value)} />
      </label>
      <br />
      <button type="submit">Login</button>
    </form>
  )
}

export default Login
