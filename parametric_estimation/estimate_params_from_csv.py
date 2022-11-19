import csv 
import numpy as np
from scipy.optimize import minimize
from scipy.integrate import solve_ivp, ode
import matplotlib.pyplot as plt

path = "/home/msccomputer/Downloads/roll.csv"

time_list = []
desired_state_list = []
state_list = []
with open(path, "r") as csvfile:
  reader = csv.reader(csvfile)
  for row in reader:
    if row[1] == '' or row[2] == '':
      break
    time_list.append(row[0])
    desired_state_list.append(row[1])
    state_list.append(row[2])

time_list = [float(t) for t in time_list[1:]]
desired_state_list = [float(ds) for ds in desired_state_list[1:]]
state_list = [float(s) for s in state_list[1:]]

# Hardcoded values for cropping
start = 250
end = 600

time_list = time_list[start:end]
state_list = state_list[start:end]
desired_state_list = desired_state_list[start:end]

def f(tau, k, x, u):
  return 1 / tau * (-x + k * u)


class LSEstimateODEParameters:
  def __init__(self, y, u, p_hat_0, dt) -> None:
    self.y = y
    self.u = u 
    self.p0 = p_hat_0
    self.dt = dt
    # self.x = 0

  def residuals(self, p_hat : np.ndarray) -> np.ndarray:
    """
    p_hat is the current parameter estimate
    p_hat = [tau_hat, k_hat]
    """
    tau_hat = p_hat[0]
    k_hat = p_hat[1] 

    errors = 0 
    x = 0
    for i in range(min(len(self.u), len(self.y))):
      x_dot = f(tau_hat, k_hat, x, self.u[i])
      x = x + self.dt * x_dot 
      y_hat = x 

      if np.isnan(y_hat - self.y[i]):
        break

      errors += np.abs(y_hat - self.y[i])  
      # print(errors)
      # print(x)
    return errors

  def optimize(self):
    optimization_results = minimize(
      fun=self.residuals,
      x0=self.p0,
      method='Nelder-Mead'
    )
    print(optimization_results)
    return optimization_results.x


k0 = 1
t0 = 0.1
dt = ((time_list[1] - time_list[0]) * 1e-3)
p0 = np.array([t0, k0], dtype=float)

ls_estimate_ode_params = LSEstimateODEParameters(state_list, desired_state_list, p0, dt)
print(ls_estimate_ode_params.optimize())

plt.plot(state_list)
plt.plot(desired_state_list)
plt.show()
