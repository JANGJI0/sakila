<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
		//controlle layer : staffId,  여러개 넘어온거 하나로 뭉쳐야한다.
		int staffId = Integer.parseInt(request.getParameter("staffId"));
		String password = request.getParameter("password");
		
		Connection conn = null;
		PreparedStatement  stmt = null;
		ResultSet rs = null;
		String listSql = "SELECT staff_id staffId, first_name firstName from staff WHERE staff_id=? and password=?";
		
		Class.forName("com.mysql.cj.jdbc.Driver");
		conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakila", "root", "java1234");
		stmt = conn.prepareStatement(listSql);
		stmt.setInt(1, staffId);
		stmt.setString(2, password);
		
		rs = stmt.executeQuery();
		
		if(rs.next()) {
			// 로그인 성공
			// isLogin = true;
			System.out.println("로그인 성공");
	        // 로그인 성공시 현재 세션영역에 loginStaff라는 변수를 생성
			session.setAttribute("loginStaff", rs.getInt("staffId"));
			response.sendRedirect("/sakila/index.jsp");
		} else {
			// 로그인 실패
			System.out.println("로그인 실패");
			response.sendRedirect("/sakila/loginForm.jsp");
		}
%>		

