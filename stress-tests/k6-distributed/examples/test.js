import { check, fail } from 'k6';
import http from 'k6/http';

const BASE_URL = 'https://apiserver-5bzpb36ewq-de.a.run.app';

export const options = {
  // A number specifying the number of VUs to run concurrently.
  vus: 1000,
  // A string specifying the total duration of the test run.
  duration: '3m',
};

// The function that defines VU logic.
//
// See https://grafana.com/docs/k6/latest/examples/get-started-with-k6/ to learn more
// about authoring k6 scripts.
//
export default function() {
  const loginData = JSON.stringify({
    username: 'test',
    password: 'test1234',
  });
  const headers = { 'Content-Type': 'application/json' };
  const loginResponse = http.post(`${BASE_URL}/login`, loginData, { headers });

  const loggedIn = check(loginResponse.json(), {
    'login success': (res) => res.status === 'ok',
  });

  if (!loggedIn) {
    fail('login failed');
  }
}
